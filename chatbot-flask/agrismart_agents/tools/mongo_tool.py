# ============================================================
# tools/mongo_tool.py — Outil d'exécution de requêtes MongoDB
# Remplace mcp_tool.py : connexion directe à MongoDB via pymongo.
# Toutes les requêtes sont en lecture seule (find).
# ============================================================

import logging
import os
from typing import Optional

from pymongo import MongoClient
from pymongo.database import Database
from pymongo.errors import PyMongoError, ServerSelectionTimeoutError

from state import AgriSmartState
from config import MONGO_URI, MONGO_DB_NAME

logger = logging.getLogger(__name__)

# ── Singleton de connexion MongoDB ──────────────────────────
# La connexion est établie une seule fois au démarrage du module
# et réutilisée pour toutes les requêtes (pool de connexions pymongo).
_mongo_client: Optional[MongoClient] = None


def _get_client() -> MongoClient:
    """
    Retourne le client MongoDB partagé (singleton).
    Crée la connexion au premier appel avec un timeout de 5000ms.

    Returns:
        MongoClient: Client pymongo connecté.

    Raises:
        ServerSelectionTimeoutError: Si MongoDB est inaccessible.
    """
    global _mongo_client
    if _mongo_client is None:
        _mongo_client = MongoClient(
            MONGO_URI,
            serverSelectionTimeoutMS=5000,   # Timeout de connexion : 5 secondes
            connectTimeoutMS=5000,
            socketTimeoutMS=10000,           # Timeout des opérations : 10 secondes
        )
    return _mongo_client


def get_db() -> Database:
    """
    Raccourci pour obtenir la base de données AgriSmart.

    Returns:
        Database: Instance pymongo de la base de données configurée.
    """
    return _get_client()[MONGO_DB_NAME]


def get_user_id_from_email(email: str) -> Optional[str]:
    """
    Résout un email en identifiant MongoDB (_id) depuis la collection 'users'.

    Cette fonction est nécessaire car :
    - Spring Boot encode l'EMAIL dans le JWT (claim 'sub')
    - MongoDB stocke les documents utilisateur avec un champ 'userId'
      contenant l'ObjectId MongoDB, PAS l'email
    - Cette fonction fait le pont entre les deux représentations

    Args:
        email: Adresse email de l'utilisateur (reçue depuis le JWT Spring Boot)

    Returns:
        str  : Identifiant MongoDB de l'utilisateur (ObjectId converti en str)
        None : Si aucun utilisateur n'est trouvé pour cet email
    """
    if not email or not email.strip():
        logger.warning("get_user_id_from_email : email vide ou None reçu.")
        return None

    try:
        db = get_db()
        # Projection minimale : on ne récupère que l'_id pour des raisons de performance
        user = db["users"].find_one({"email": email.strip()}, {"_id": 1})

        if user:
            user_id = str(user["_id"])
            logger.debug("Résolution email → userId : %s → %s", email, user_id)
            return user_id

        logger.warning(
            "Aucun utilisateur trouvé pour l'email : %s", email
        )
        return None

    except PyMongoError as e:
        logger.error(
            "Erreur MongoDB lors de la résolution de l'email '%s' : %s", email, e
        )
        return None
    except Exception as e:
        logger.error(
            "Erreur inattendue lors de la résolution de l'email '%s' : %s", email, e
        )
        return None


def execute_mongo_query(
    collection: str,
    filter_doc: dict,
    projection: Optional[dict] = None,
    limit: int = 50,
) -> list:
    """
    Exécute une requête de lecture (find) sur une collection MongoDB.

    Args:
        collection  : Nom de la collection cible
        filter_doc  : Filtre pymongo (équivalent du WHERE en SQL)
        projection  : Champs à inclure/exclure (None = tout retourner)
        limit       : Nombre maximum de documents retournés (défaut: 50)

    Returns:
        list: Liste de documents MongoDB (les ObjectId sont convertis en str).

    Raises:
        Exception: En cas d'erreur de connexion ou d'exécution.
    """
    client = _get_client()
    db = client[MONGO_DB_NAME]
    col = db[collection]

    cursor = col.find(filter_doc, projection).limit(limit)
    results = []

    for doc in cursor:
        # Conversion de l'ObjectId en string pour la sérialisation JSON
        if "_id" in doc:
            doc["_id"] = str(doc["_id"])
        results.append(doc)

    return results


def get_user_data(user_id: str, collection: str) -> list:
    """
    Raccourci pour récupérer les documents d'un utilisateur spécifique.
    Ajoute automatiquement {"userId": user_id} dans le filtre.

    Args:
        user_id    : Identifiant de l'utilisateur (email ou _id)
        collection : Nom de la collection cible

    Returns:
        list: Documents appartenant à l'utilisateur.
    """
    return execute_mongo_query(
        collection=collection,
        filter_doc={"userId": user_id},
    )


def get_collections_for_role(role: str) -> list:
    """Retourne la liste des collections autorisées."""
    from config import ALLOWED_TABLES_BY_ROLE
    return ALLOWED_TABLES_BY_ROLE.get(role, [])


def save_chat_message(user_email: str, role: str, content: str, diagnostic: Optional[str] = None):
    """
    Enregistre un message dans la collection 'chat_history'.
    """
    try:
        db = get_db()
        doc = {
            "user_email": user_email,
            "role": role, # "user" or "assistant"
            "content": content,
            "diagnostic": diagnostic,
            "timestamp": _get_current_time_str()
        }
        db["chat_history"].insert_one(doc)
    except Exception as e:
        logger.error(f"Erreur lors de la sauvegarde du message : {e}")


def get_chat_history(user_email: str, limit: int = 20) -> list:
    """
    Récupère l'historique récent des conversations.
    """
    try:
        db = get_db()
        cursor = db["chat_history"].find({"user_email": user_email}).sort("timestamp", -1).limit(limit)
        history = []
        for doc in cursor:
            history.append({
                "role": doc["role"],
                "content": doc["content"]
            })
        return history[::-1] # Ordre chronologique
    except Exception as e:
        logger.error(f"Erreur lors de la récupération de l'historique : {e}")
        return []


def _get_current_time_str() -> str:
    from datetime import datetime
    return datetime.utcnow().isoformat()


def check_connection() -> dict:
    """
    Vérifie l'état de la connexion MongoDB.
    Utilisé par l'endpoint /health du Flask.

    Returns:
        dict: {"status": "connected"} ou {"status": "error", "message": "..."}
    """
    try:
        client = _get_client()
        # Commande ping légère pour tester la connexion
        client.admin.command("ping")
        return {"status": "connected"}
    except ServerSelectionTimeoutError:
        return {"status": "error", "message": "Timeout : MongoDB inaccessible."}
    except PyMongoError as e:
        return {"status": "error", "message": str(e)}
    except Exception as e:
        return {"status": "error", "message": f"Erreur inattendue : {str(e)}"}


def mongo_tool_node(state: AgriSmartState) -> AgriSmartState:
    """
    Nœud d'exécution MongoDB : exécute le filtre généré par db_agent
    et stocke les résultats dans state["mongo_result"].

    Cas gérés :
    - Si mongo_query est None (accès refusé en amont), le nœud passe sans rien faire.
    - Si MongoDB retourne une erreur, elle est stockée dans state["error"].
    - Si la requête réussit, les résultats sont dans state["mongo_result"].

    Retourne le state mis à jour.
    """
    # Si aucune requête n'a été générée (ex: accès refusé par db_agent), on ne fait rien
    if not state.get("mongo_query"):
        return state

    mongo_query = state["mongo_query"]
    collection = mongo_query.get("collection")
    filter_doc = mongo_query.get("filter", {})
    projection = mongo_query.get("projection")

    if not collection:
        return {
            **state,
            "mongo_result": None,
            "error": "Nom de collection manquant dans mongo_query.",
        }

    try:
        results = execute_mongo_query(
            collection=collection,
            filter_doc=filter_doc,
            projection=projection,
        )
        return {
            **state,
            "mongo_result": results,
            "error": None,
        }

    except ServerSelectionTimeoutError:
        return {
            **state,
            "mongo_result": None,
            "error": "Timeout : impossible de se connecter à MongoDB. Vérifiez que le service est démarré.",
        }
    except PyMongoError as e:
        return {
            **state,
            "mongo_result": None,
            "error": f"Erreur MongoDB : {str(e)}",
        }
    except Exception as e:
        return {
            **state,
            "mongo_result": None,
            "error": f"Erreur inattendue lors de la requête MongoDB : {str(e)}",
        }
