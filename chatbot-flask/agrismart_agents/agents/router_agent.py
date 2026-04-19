# ============================================================
# agents/router_agent.py — Agent de routage des intentions
# Classifie la requête utilisateur en une des 4 catégories :
#   guide_ui | query_db | info_agri | unknown
# ============================================================

import json

from langchain_core.messages import SystemMessage, HumanMessage

from state import AgriSmartState
from config import get_llm


# Prompt système du routeur — paramétré avec le rôle utilisateur.
# Robuste : gère les fautes d'orthographe, les variations linguistiques,
# les messages sociaux, et exploite le rôle pour lever les ambiguïtés.
SYSTEM_PROMPT_TEMPLATE = """
Tu es un routeur intelligent pour l'application AgriSmart.
Rôle de l'utilisateur connecté : {user_role}

Ta seule tâche est de classer la requête dans UNE des catégories suivantes.
Ne réponds JAMAIS au fond de la question. Retourne uniquement le JSON de classification.

CATÉGORIES :
- guide_ui   : navigation (ex: "où est le marketplace", "comment s'inscrire")
- query_db   : données en base (ex: "mes parcelles", "mon stock", "prix des tomates")
- info_agri  : expertise agricole, maladies, conseils (ex: "mildiou", "rouille", "maïs")
- unknown    : social (ex: "bonjour", "merci") ou hors-sujet

EXEMPLES DE CLASSIFICATION (FEW-SHOT) :
- "Expliquez-moi plus sur la maladie : Rouille Commune du Maïs" -> {{"intent": "info_agri"}}
- "Comment traiter le mildiou de la tomate ?" -> {{"intent": "info_agri"}}
- "C'est quoi l'irrigation ?" -> {{"intent": "info_agri"}}
- "Quels produits sont au marché ?" -> {{"intent": "query_db"}}
- "Prix des tomates au marché" -> {{"intent": "query_db"}}
- "Où puis-je voir mes capteurs ?" -> {{"intent": "guide_ui"}}
- "Ouvrir le marché" -> {{"intent": "guide_ui"}}

RÈGLES STRICTES :
1. Si la question porte sur une MALADIE, un SYMPTÔME, ou le MAÏS -> info_agri.
2. Si l'utilisateur demande des INFOS sur des produits, articles ou prix (même s'il mentionne "marché") -> query_db.
3. Si l'utilisateur veut juste TROUVER ou OUVRIR la page du marché -> guide_ui.
4. Si c'est une salutation -> unknown.
5. Ne réponds qu'avec le JSON.

Réponds UNIQUEMENT avec ce JSON, sans texte supplémentaire :
{{"intent": "<catégorie>"}}
""".strip()


def router_node(state: AgriSmartState) -> AgriSmartState:
    """
    Nœud de routage : analyse la requête utilisateur via LLM et détermine l'intention.
    Le rôle utilisateur est injecté dans le prompt pour lever les ambiguïtés.

    Retourne le state enrichi avec le champ 'intent' rempli.
    En cas d'échec du parsing JSON, 'intent' est mis à "unknown" par sécurité.
    """
    llm = get_llm()
    user_role = state.get("user_role", "visiteur")

    system_prompt = SYSTEM_PROMPT_TEMPLATE.format(user_role=user_role)

    messages = [
        SystemMessage(content=system_prompt),
        HumanMessage(content=state["user_query"]),
    ]

    try:
        # Appel au LLM pour classifier l'intention
        response = llm.invoke(messages)
        content = response.content.strip()

        # Nettoyage au cas où le LLM encadre la réponse dans des backticks markdown
        if content.startswith("```"):
            parts = content.split("```")
            content = parts[1] if len(parts) > 1 else content
            if content.startswith("json"):
                content = content[4:].strip()

        # Parsing du JSON retourné
        parsed = json.loads(content)
        intent = parsed.get("intent", "unknown")

        # Validation : s'assurer que l'intention est dans la liste autorisée
        valid_intents = {"guide_ui", "query_db", "info_agri", "unknown"}
        if intent not in valid_intents:
            intent = "unknown"

    except (json.JSONDecodeError, KeyError, Exception):
        # En cas d'erreur de parsing ou d'appel LLM, dégradation vers "unknown"
        intent = "unknown"

    return {**state, "intent": intent}
