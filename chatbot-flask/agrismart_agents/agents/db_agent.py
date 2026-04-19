# ============================================================
# agents/db_agent.py — Agent de génération de requêtes MongoDB sécurisé
# Traduit la requête utilisateur en un filtre MongoDB (JSON) tout en
# respectant les droits d'accès par rôle et les règles de sécurité.
#
# Flux dans le graphe LangGraph :
#   db_agent_node → génère state["mongo_query"]
#   mcp_tool_node → envoie la requête au MCP server (POST HTTP)
#   answer_db_node → reformule les résultats en langage naturel
# ============================================================

import json

from langchain_core.messages import SystemMessage, HumanMessage

from state import AgriSmartState
from config import (
    get_llm, ALLOWED_TABLES_BY_ROLE, COLLECTION_ALIASES,
    SENSITIVE_FIELDS, DB_SCHEMA_STR, PUBLIC_COLLECTIONS, USER_FIELD_BY_COLLECTION,
)


# ── Étape 1 : le LLM identifie UNIQUEMENT la collection et un mot-clé optionnel ──
# Il ne génère PAS le filtre MongoDB — c'est Python qui le construit ensuite.
STEP1_PROMPT_TEMPLATE = """
Tu es un agent de sélection de collection MongoDB pour AgriSmart.
Rôle de l'utilisateur : {user_role}

Collections DISPONIBLES pour ce rôle :
{allowed_tables}

Schéma des collections :
{db_schema}

Ta tâche : analyser la demande et retourner UNIQUEMENT ce JSON :
{{
  "collection": "<nom_exact_de_la_collection>",
  "keyword": "<valeur_de_filtrage_si_mentionnée_sinon_null>"
}}

RÈGLES :
- "collection" : choisis la collection la plus pertinente parmi celles disponibles.
- "keyword" : si l'utilisateur mentionne un nom de produit/culture/statut spécifique,
  mets cette valeur ici. Sinon null.
  Exemples : "prix de tomates" → keyword="Tomates"
             "mes stocks" → keyword=null
             "formations sur l'irrigation" → keyword="irrigation"
- Si la demande est hors périmètre : {{"error": "raison courte"}}
- Ne génère JAMAIS de filtre MongoDB complet ici.

Réponds UNIQUEMENT avec le JSON, sans texte supplémentaire.
""".strip()

# Opérateurs MongoDB dangereux — interdits dans tout filtre
FORBIDDEN_OPERATORS = [
    "$where", "$function", "$accumulator",
    "$merge", "$out", "$lookup", "$unionWith",
    "$graphLookup",
]


def _build_filter(collection: str, keyword: str | None, user_id: str, user_email: str) -> dict:
    """
    Construit le filtre MongoDB selon la collection et le contexte utilisateur.

    Approche fetch-then-filter :
    - Collections PUBLIQUES (offers, products, courses…) :
        * Pas de filtre utilisateur
        * Filtre par mot-clé si fourni (case-insensitive)
    - Collections PRIVÉES :
        * Filtre par le champ userId propre à la collection
        * + filtre mot-clé si fourni
    """
    filter_doc: dict = {}

    # ── Filtre utilisateur pour les collections privées ──
    if collection not in PUBLIC_COLLECTIONS:
        user_field = USER_FIELD_BY_COLLECTION.get(collection)
        if user_field == "ownerEmail" and user_email:
            filter_doc[user_field] = user_email
        elif user_field == "_id" and user_id:
            from bson import ObjectId
            try:
                filter_doc["_id"] = ObjectId(user_id)
            except Exception:
                filter_doc["_id"] = user_id
        elif user_field and user_id:
            filter_doc[user_field] = user_id

    # ── Filtre mot-clé (case-insensitive) ──
    if keyword:
        keyword_lower = keyword.lower().strip()

        # Cas spécial : campagnes — "active/actives" filtre par status, pas par nom
        if collection == "campaigns":
            status_map = {
                "active": "active", "actif": "active", "actives": "active", "actifs": "active",
                "en cours": "active",
                "planifié": "planned", "planifiée": "planned", "à venir": "planned",
                "future": "planned", "futures": "planned", "planned": "planned",
                "terminé": "completed", "terminée": "completed", "completed": "completed",
            }
            if keyword_lower in status_map:
                filter_doc["status"] = status_map[keyword_lower]
            else:
                filter_doc["name"] = {"$regex": keyword, "$options": "i"}

        # Cas spécial : tâches — "futures/prochaines" filtre par dueDate >= maintenant
        elif collection == "tasks" and keyword_lower in {
            "futures", "future", "à venir", "prochaines", "prochain", "upcoming"
        }:
            from datetime import datetime, timezone
            filter_doc["dueDate"] = {"$gte": datetime.now(timezone.utc)}

        else:
            # Détermine le champ de recherche textuelle selon la collection
            keyword_field_map = {
                "offers":    "product",
                "products":  "name",
                "courses":   "title",
                "tasks":     "title",
                "plans":     "title",
                "campaigns": "name",
                "supportTickets": "subject",
                "alerts":    "title",
                "notifications": "title",
            }
            kf = keyword_field_map.get(collection)
            if kf:
                filter_doc[kf] = {"$regex": keyword, "$options": "i"}

    return filter_doc


def db_agent_node(state: AgriSmartState) -> AgriSmartState:
    """
    Nœud de génération MongoDB — approche fetch-then-filter.

    Étape 1 : le LLM identifie la collection et un éventuel mot-clé.
    Étape 2 : Python construit le filtre MongoDB correct (pas le LLM).

    Cela évite que le LLM génère de mauvais noms de champs ou de mauvais filtres.
    """
    user_role  = state.get("user_role", "visiteur")
    user_id    = state.get("user_id", "")
    user_email = state.get("user_email", "")

    # ── Vérification des droits d'accès ─────────────────────
    allowed_collections = ALLOWED_TABLES_BY_ROLE.get(user_role, [])

    if not allowed_collections:
        return {
            **state,
            "mongo_query": None,
            "final_response": (
                "Accès refusé : votre rôle ne vous permet pas d'interroger "
                "la base de données AgriSmart."
            ),
            "error": f"Rôle '{user_role}' : aucune collection autorisée.",
        }

    allowed_str = "\n".join(f"- {c}" for c in allowed_collections)

    # ── Étape 1 : LLM identifie la collection + mot-clé ─────
    system_prompt = STEP1_PROMPT_TEMPLATE.format(
        user_role=user_role,
        allowed_tables=allowed_str,
        db_schema=DB_SCHEMA_STR,
    )

    llm = get_llm()
    messages = [
        SystemMessage(content=system_prompt),
        HumanMessage(content=state["user_query"]),
    ]

    try:
        response = llm.invoke(messages)
        content  = response.content.strip()

        # Nettoyage des éventuels blocs markdown
        if content.startswith("```"):
            parts   = content.split("```")
            content = parts[1] if len(parts) > 1 else content
            if content.lower().startswith("json"):
                content = content[4:].strip()

        parsed = json.loads(content)

        # Le LLM signale une impossibilité
        if "error" in parsed:
            return {
                **state,
                "mongo_query": None,
                "final_response": (
                    f"Impossible de traiter cette demande : {parsed['error']}"
                ),
                "error": parsed["error"],
            }

        collection = parsed.get("collection", "").strip()
        keyword    = parsed.get("keyword") or None

        # ── Résolution des alias ──────────────────────────────
        if collection in COLLECTION_ALIASES:
            collection = COLLECTION_ALIASES[collection]

        if not collection:
            return {
                **state,
                "mongo_query": None,
                "final_response": "Aucune collection cible n'a pu être déterminée.",
                "error": "Le LLM n'a pas renseigné le champ 'collection'.",
            }

        # ── Validation : collection autorisée pour ce rôle ──
        if collection not in allowed_collections:
            return {
                **state,
                "mongo_query": None,
                "final_response": (
                    f"Accès refusé : la collection '{collection}' "
                    "n'est pas accessible avec votre rôle."
                ),
                "error": f"Collection non autorisée pour '{user_role}': {collection}",
            }

        # ── Étape 2 : Python construit le filtre correct ─────
        filter_doc = _build_filter(collection, keyword, user_id, user_email)

        # Sécurité : interdiction des opérateurs dangereux
        filter_str = json.dumps(filter_doc)
        for op in FORBIDDEN_OPERATORS:
            if op in filter_str:
                return {
                    **state,
                    "mongo_query": None,
                    "final_response": "Requête refusée : opérateur non autorisé détecté.",
                    "error": f"Opérateur MongoDB interdit : {op}",
                }

        # Projection : exclure les champs sensibles
        projection = {field: 0 for field in SENSITIVE_FIELDS}

        mongo_query = {
            "collection": collection,
            "filter":     filter_doc,
            "projection": projection,
        }

    except json.JSONDecodeError as e:
        return {
            **state,
            "mongo_query": None,
            "final_response": "Erreur lors du parsing de la réponse LLM.",
            "error": f"JSONDecodeError : {str(e)}",
        }
    except Exception as e:
        return {
            **state,
            "mongo_query": None,
            "final_response": "Erreur lors de la génération de la requête.",
            "error": str(e),
        }

    return {**state, "mongo_query": mongo_query}
