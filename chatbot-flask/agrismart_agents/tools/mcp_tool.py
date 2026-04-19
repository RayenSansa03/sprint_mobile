# ============================================================
# tools/mcp_tool.py — Nœud LangGraph qui délègue l'exécution
# des requêtes MongoDB au serveur MCP (microservice port 5001).
#
# Rôle dans le graphe :
#   db_agent_node  → génère state["mongo_query"]
#   mcp_tool_node  → envoie la requête au MCP server via HTTP POST
#   answer_db_node → reformule les résultats en langage naturel
#
# Le MCP server (mcp_server/app.py) est le seul processus qui touche
# directement MongoDB — les agents LangGraph n'accèdent jamais à
# pymongo directement.
# ============================================================

import logging
import os

import requests
from requests.exceptions import ConnectionError, Timeout, RequestException

from state import AgriSmartState

logger = logging.getLogger(__name__)

# URL du MCP server — configurable via .env
MCP_SERVER_URL = os.getenv("MCP_SERVER_URL", "http://localhost:5001/execute")

# Timeout HTTP vers le MCP server (secondes)
MCP_TIMEOUT = int(os.getenv("MCP_TIMEOUT", 10))


def execute_via_mcp(
    collection: str,
    filter_doc: dict,
    projection: dict | None = None,
    limit: int = 50,
) -> dict:
    """
    Envoie une requête MongoDB au MCP server via HTTP POST et retourne
    la réponse JSON brute.

    Structure du body envoyé au MCP server :
    {
        "collection": "parcelles",
        "filter":     {"userId": "64abc..."},
        "projection": {"nom": 1, "surface": 1},
        "limit":      50
    }

    Structure de la réponse attendue (succès) :
    {
        "status":  "ok",
        "count":   3,
        "results": [...]
    }

    Args:
        collection : Nom de la collection MongoDB cible
        filter_doc : Filtre de lecture (dict pymongo)
        projection : Champs à inclure/exclure (None = tout)
        limit      : Nombre maximum de documents à retourner

    Returns:
        dict : Réponse JSON du MCP server (toujours un dict)

    Raises:
        ConnectionError : Si le MCP server est inaccessible
        Timeout         : Si la requête dépasse MCP_TIMEOUT secondes
        RequestException: Pour toute autre erreur HTTP
    """
    body = {
        "collection": collection,
        "filter":     filter_doc,
        "limit":      limit,
    }
    # Inclure la projection uniquement si elle est définie
    if projection is not None:
        body["projection"] = projection

    logger.debug(
        "→ MCP POST %s | collection=%s | filter=%s",
        MCP_SERVER_URL, collection, filter_doc
    )

    response = requests.post(
        MCP_SERVER_URL,
        json=body,
        timeout=MCP_TIMEOUT,
    )
    response.raise_for_status()
    return response.json()


def mcp_tool_node(state: AgriSmartState) -> AgriSmartState:
    """
    Nœud d'exécution MCP : lit state["mongo_query"] généré par db_agent,
    l'envoie au MCP server pour exécution MongoDB, et stocke les résultats
    dans state["mongo_result"].

    Cas gérés :
    - mongo_query absent (None) → le nœud passe sans action
    - Champ 'collection' manquant → erreur stockée dans state["error"]
    - MCP server inaccessible → erreur réseau dans state["error"]
    - Réponse MCP avec status="error" → erreur propagée dans state["error"]
    - Succès → résultats dans state["mongo_result"]

    Args:
        state : État LangGraph courant

    Returns:
        AgriSmartState : État mis à jour avec mongo_result et/ou error
    """
    # Cas 1 : aucune requête générée (ex : accès refusé par db_agent)
    if not state.get("mongo_query"):
        return state

    mongo_query = state["mongo_query"]
    collection  = mongo_query.get("collection", "").strip()
    filter_doc  = mongo_query.get("filter", {})
    projection  = mongo_query.get("projection")

    # Cas 2 : collection manquante
    if not collection:
        logger.error("mcp_tool_node : champ 'collection' absent dans mongo_query")
        return {
            **state,
            "mongo_result": None,
            "error": "Nom de collection manquant dans la requête générée par db_agent.",
        }

    try:
        # ── Appel au MCP server ──────────────────────────────
        mcp_response = execute_via_mcp(
            collection=collection,
            filter_doc=filter_doc,
            projection=projection,
        )

        # Cas 3 : le MCP server retourne une erreur métier
        if mcp_response.get("status") == "error":
            error_msg = mcp_response.get("error", "Erreur inconnue du MCP server.")
            logger.error("MCP server erreur métier : %s", error_msg)
            return {
                **state,
                "mongo_result": None,
                "error": f"Erreur MCP : {error_msg}",
            }

        # Cas 4 : succès — extraction des résultats
        results = mcp_response.get("results", [])
        logger.info(
            "mcp_tool_node : %d documents reçus depuis MCP (collection=%s)",
            len(results), collection
        )

        return {
            **state,
            "mongo_result": results,
            "error": None,
        }

    except ConnectionError:
        logger.error("mcp_tool_node : MCP server inaccessible à %s", MCP_SERVER_URL)
        return {
            **state,
            "mongo_result": None,
            "error": (
                f"Le serveur MCP est inaccessible ({MCP_SERVER_URL}). "
                "Vérifiez que mcp_server/app.py est démarré sur le port 5001."
            ),
        }

    except Timeout:
        logger.error("mcp_tool_node : timeout après %ds vers %s", MCP_TIMEOUT, MCP_SERVER_URL)
        return {
            **state,
            "mongo_result": None,
            "error": f"Timeout : le serveur MCP n'a pas répondu en {MCP_TIMEOUT}s.",
        }

    except RequestException as e:
        logger.error("mcp_tool_node : erreur HTTP → %s", str(e))
        return {
            **state,
            "mongo_result": None,
            "error": f"Erreur HTTP vers le MCP server : {str(e)}",
        }

    except Exception as e:
        logger.error("mcp_tool_node : erreur inattendue → %s", str(e))
        return {
            **state,
            "mongo_result": None,
            "error": f"Erreur inattendue dans mcp_tool_node : {str(e)}",
        }
