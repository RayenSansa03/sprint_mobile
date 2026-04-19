# ============================================================
# agents/answer_db_agent.py — Agent de reformulation des résultats MongoDB
# Transforme les données brutes retournées par la base de données
# en une réponse naturelle, concise et adaptée au rôle utilisateur.
# SÉCURITÉ : filtre les champs sensibles avant injection dans le LLM.
# ============================================================

import json

from langchain_core.messages import SystemMessage, HumanMessage

from state import AgriSmartState
from config import get_llm, SENSITIVE_FIELDS


# Template du prompt système — paramétré avec la question, les données et le rôle
SYSTEM_PROMPT_TEMPLATE = """
Tu es un assistant AgriSmart expert qui présente des données agricoles de façon claire et utile.
Rôle de l'utilisateur : {user_role}

Question originale : {original_query}
Collection interrogée : {collection}

Données retournées :
{db_result}

CONSIGNES GÉNÉRALES :
- Formule une réponse naturelle, structurée et utile EN FRANÇAIS.
- Adapte le niveau de détail au rôle : agriculteur (pratique et concret), admin (exhaustif).
- N'invente AUCUNE donnée absente du résultat.
- Ne mentionne JAMAIS les noms de collections techniques (ex: "tasks", "campaigns", "plots").
- Utilise des termes métier : "tâches" pas "tasks", "campagnes" pas "campaigns", etc.

RÈGLES SELON LE TYPE DE DONNÉES :
- Tâches/planning : liste les tâches avec titre, date d'échéance et statut. Indique si une tâche
  est urgente (dueDate proche). Si liste vide → "Aucune tâche trouvée pour votre compte.
  Vous pouvez en créer depuis /app/planning."
- Campagnes : présente nom, zone, dates et statut. Précise le nombre de participants si dispo.
  Si liste vide → "Aucune campagne active en ce moment. Consultez /app/agro-marche pour les
  prochaines campagnes."
- Offres/prix : présente les prix clés (produit, prix, unité, disponibilité). Groupe par produit.
- Commandes/stocks : résumé quantitatif (totaux, statuts).
- Données volumineuses (>5 éléments) : fais un résumé avec les 3-5 éléments les plus pertinents
  et indique le total.
- Résultat vide pour données personnelles : ne pas dire "vous n'avez pas X" de façon définitive.
  Suggère d'abord une action ou explique comment en créer.

FORMAT DE RÉPONSE :
- Commence directement par l'information (pas "Voici...", pas "Bien sûr...").
- Utilise des listes à puces (•) pour plusieurs éléments.
- Mets en gras les informations clés si pertinent.
- Termine par un lien de navigation si une action est possible (ex: /app/planning).
""".strip()


def _sanitize_docs(docs: list) -> list:
    """
    Supprime les champs sensibles des documents avant injection dans le LLM.
    Protège contre la fuite d'emails, tokens, passwords via le contexte LLM.
    """
    sanitized = []
    for doc in docs:
        if isinstance(doc, dict):
            sanitized.append({k: v for k, v in doc.items() if k not in SENSITIVE_FIELDS})
        else:
            sanitized.append(doc)
    return sanitized


def answer_db_node(state: AgriSmartState) -> AgriSmartState:
    """
    Nœud de reformulation : convertit le résultat brut de la BDD
    en langage naturel compréhensible, adapté au rôle utilisateur.

    Sécurité : les champs sensibles (email, token, password...) sont
    supprimés des documents AVANT d'être envoyés au LLM.
    """
    # ── Cas : erreur en amont sans résultat disponible ──────
    if state.get("error") and state.get("mongo_result") is None:
        error_msg = state.get("error", "")
        # Construire un message utilisateur lisible selon le type d'erreur
        if "inaccessible" in error_msg or "Timeout" in error_msg:
            user_msg = ("Le service de données est momentanément indisponible. "
                        "Veuillez réessayer dans quelques instants.")
        elif "non autorisée" in error_msg or "403" in error_msg:
            user_msg = ("Je n'ai pas accès à ces données pour votre compte. "
                        "Vérifiez vos droits auprès de l'administrateur.")
        elif "Accès refusé" in error_msg:
            user_msg = state.get("final_response") or ("Accès refusé : vous n'êtes pas "
                        "autorisé à consulter ces informations.")
        else:
            user_msg = ("Impossible de récupérer vos données pour le moment. "
                        f"Détail : {error_msg}")
        return {**state, "final_response": user_msg}

    # ── Extraction des métadonnées de la requête ─────────────
    user_role  = state.get("user_role", "inconnu")
    mongo_query = state.get("mongo_query") or {}
    collection  = mongo_query.get("collection", "données")

    # ── Sérialisation sécurisée du résultat brut ─────────────
    mongo_result = state.get("mongo_result")
    if mongo_result is None:
        db_result_str = "Aucun résultat retourné par la base de données."
    elif isinstance(mongo_result, list):
        if len(mongo_result) == 0:
            db_result_str = "Aucun document trouvé pour cette requête."
        else:
            # Filtrage des champs sensibles avant injection LLM
            safe_docs = _sanitize_docs(mongo_result)
            db_result_str = json.dumps(safe_docs, ensure_ascii=False, indent=2)
    else:
        db_result_str = str(mongo_result)

    # ── Construction du prompt ────────────────────────────────
    system_prompt = SYSTEM_PROMPT_TEMPLATE.format(
        user_role=user_role,
        original_query=state["user_query"],
        collection=collection,
        db_result=db_result_str,
    )

    # ── Appel LLM pour la reformulation ──────────────────────
    llm = get_llm()
    messages = [
        SystemMessage(content=system_prompt),
        HumanMessage(content="Formule la réponse en français."),
    ]

    try:
        response = llm.invoke(messages)
        final_response = response.content.strip()
    except Exception as e:
        return {
            **state,
            "final_response": "Erreur lors de la formulation de la réponse.",
            "error": str(e),
        }

    return {**state, "final_response": final_response}
