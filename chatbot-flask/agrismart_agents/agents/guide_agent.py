# ============================================================
# agents/guide_agent.py — Agent de guidage de l'interface UI
# Charge le catalogue de navigation selon le rôle utilisateur
# et répond en langage naturel en français.
# ============================================================

import json
import os

from langchain_core.messages import SystemMessage, HumanMessage

from state import AgriSmartState
from config import get_llm, CATALOG_PATH


# Template du prompt système — injecté dynamiquement avec le rôle et le guide
SYSTEM_PROMPT_TEMPLATE = """
Tu es AgriSmart Navigator, l'assistant de navigation de l'application AgriSmart.
Rôle de l'utilisateur : {user_role}

Guide de navigation disponible (JSON) :
{guide_content}

CONSIGNES :
1. Réponds en français, en langage naturel et de façon concise (max 3 phrases).
2. Guide l'utilisateur vers la bonne page — indique TOUJOURS l'URL (suggested_pages).
3. Si la question ne correspond pas exactement à une entrée du guide, INFÈRE la page
   la plus proche sémantiquement (ex: "acheter des semences" → marketplace).
4. Si plusieurs pages correspondent, liste-les avec leurs URLs.
5. Si aucune page ne correspond du tout, propose les 2-3 sections principales
   disponibles pour ce rôle.
6. Ne dis JAMAIS "je n'ai pas cette information" sans proposer une alternative.
7. Adapte le vocabulaire au rôle : agriculteur (simple/pratique), admin (technique).

Mentionne toujours le champ "suggested_pages" pour indiquer l'URL à visiter.
Ne génère aucune information absente de ce guide.
Si la question ne correspond à aucune entrée du guide, dis-le clairement.
""".strip()


def _load_catalog(base_dir: str) -> dict:
    """
    Charge le fichier JSON du catalogue de navigation depuis le chemin configuré.

    Args:
        base_dir: Répertoire racine du module agrismart_agents.

    Returns:
        dict: Contenu du catalogue, ou dict vide si le fichier est introuvable.

    Raises:
        FileNotFoundError: Si le fichier catalog est absent.
    """
    catalog_path = os.path.join(base_dir, CATALOG_PATH)
    with open(catalog_path, "r", encoding="utf-8") as f:
        return json.load(f)


def guide_node(state: AgriSmartState) -> AgriSmartState:
    """
    Nœud de guidage UI : charge le catalogue de navigation pour le rôle utilisateur
    et génère une réponse en langage naturel via LLM.

    Étapes :
    1. Chargement du fichier providers_catalog.json
    2. Extraction de la section correspondant au rôle de l'utilisateur
    3. Construction du prompt dynamique
    4. Appel LLM et retour de la réponse finale

    Retourne le state enrichi avec le champ 'final_response'.
    """
    # Résolution du chemin absolu du répertoire racine du module
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    # Chargement du catalogue de navigation
    try:
        catalog = _load_catalog(base_dir)
    except FileNotFoundError:
        return {
            **state,
            "final_response": "Erreur interne : le catalogue de navigation est introuvable.",
            "error": f"Fichier de catalogue absent : {os.path.join(base_dir, CATALOG_PATH)}",
        }
    except json.JSONDecodeError as e:
        return {
            **state,
            "final_response": "Erreur interne : le catalogue de navigation est corrompu.",
            "error": f"Erreur JSON : {str(e)}",
        }

    # Extraction du guide pour le rôle utilisateur
    user_role = state.get("user_role", "visiteur")
    role_guide = catalog.get(user_role)

    if not role_guide:
        return {
            **state,
            "final_response": (
                f"Désolé, je n'ai pas de guide de navigation disponible pour le rôle "
                f"'{user_role}'. Veuillez contacter l'administrateur AgriSmart."
            ),
        }

    # Sérialisation du guide pour injection dans le prompt
    guide_content = json.dumps(role_guide, ensure_ascii=False, indent=2)

    system_prompt = SYSTEM_PROMPT_TEMPLATE.format(
        user_role=user_role,
        guide_content=guide_content,
    )

    # Appel au LLM pour générer la réponse de navigation
    llm = get_llm()
    messages = [
        SystemMessage(content=system_prompt),
        HumanMessage(content=state["user_query"]),
    ]

    try:
        response = llm.invoke(messages)
        final_response = response.content.strip()
    except Exception as e:
        return {
            **state,
            "final_response": "Erreur lors de la génération de la réponse de navigation.",
            "error": str(e),
        }

    return {**state, "final_response": final_response}
