# ============================================================
# mcp_server/app.py — Serveur MCP d'exécution des requêtes MongoDB
#
# Ce microservice est le serveur d'exécution central du système multi-agents
# AgriSmart. Il reçoit les requêtes construites par db_agent (collection +
# filter + projection) via HTTP POST, les exécute contre MongoDB, et retourne
# les résultats en JSON.
#
# Rôle dans l'architecture :
#   db_agent (LangGraph)
#       └─→ POST /execute  (mcp_tool_node)
#               └─→ MCP Server  ← ici
#                       └─→ MongoDB → résultats → mcp_tool_node → answer_db_node
#
# Port par défaut : 5001
# Endpoint principal : POST /execute
# ============================================================

import os
import logging

from bson import ObjectId
from dotenv import load_dotenv
from flask import Flask, request, jsonify
from flask_cors import CORS
from pymongo import MongoClient
from pymongo.errors import PyMongoError, ServerSelectionTimeoutError

# Chargement des variables d'environnement depuis .env (deux niveaux plus haut)
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "..", ".env"))

# ── Journalisation ───────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="[MCP Server] %(asctime)s %(levelname)s — %(message)s",
)
logger = logging.getLogger(__name__)

# ── Configuration MongoDB ────────────────────────────────────
MONGO_URI     = os.getenv("MONGO_URI", "mongodb://localhost:27017")
MONGO_DB_NAME = os.getenv("MONGO_DB_NAME", "agrismart")
MCP_PORT      = int(os.getenv("MCP_SERVER_PORT", 5001))

# ── Singleton MongoDB ────────────────────────────────────────
_mongo_client: MongoClient | None = None


def _get_client() -> MongoClient:
    """
    Retourne le client MongoDB partagé (singleton).
    Connexion établie à la première requête.
    """
    global _mongo_client
    if _mongo_client is None:
        _mongo_client = MongoClient(
            MONGO_URI,
            serverSelectionTimeoutMS=5000,
            connectTimeoutMS=5000,
            socketTimeoutMS=10000,
        )
    return _mongo_client


def _serialize_doc(doc: dict) -> dict:
    """
    Convertit les types MongoDB non-JSON-sérialisables (ObjectId, datetime, etc.)
    en chaînes de caractères.
    """
    from datetime import datetime
    serialized = {}
    for k, v in doc.items():
        if isinstance(v, ObjectId):
            serialized[k] = str(v)
        elif isinstance(v, datetime):
            serialized[k] = v.isoformat()
        elif isinstance(v, dict):
            serialized[k] = _serialize_doc(v)
        elif isinstance(v, list):
            serialized[k] = [
                _serialize_doc(i) if isinstance(i, dict)
                else i.isoformat() if isinstance(i, datetime)
                else str(i) if isinstance(i, ObjectId)
                else i for i in v
            ]
        else:
            serialized[k] = v
    return serialized


# ── Application Flask ────────────────────────────────────────
app = Flask(__name__)
CORS(app)

# Collections accessibles via MCP (liste blanche de sécurité)
# Synchronisé avec les noms RÉELS des collections MongoDB AgriSmart (vérifiés en base).
ALLOWED_COLLECTIONS = {
    # Auth / utilisateurs
    "users", "roles", "permissions", "rolePermissions",
    "userSessions", "signupRequests", "roleUpgradeRequests",
    # Marketplace
    "offers", "products", "productImages",
    "orders", "orderItems", "payments", "stocks",
    # Agriculture
    "plots", "plans", "planning", "tasks", "taskNotifications",
    "yieldPredictions", "cropCycles", "crops",
    # IoT / capteurs
    "sensors", "sensorReadings", "devices", "deviceAlerts",
    "diseaseDetections", "aiDiagnoses",
    # Support / notifications
    "supportTickets", "ticketMessages",
    "alerts", "notifications", "auditLogs",
    # Cooperative
    "cooperatives", "cooperativeMembers", "cooperativePlans", "cooperativeReports",
    # Formation
    "courses", "courseModules", "enrollments", "learningResources", "moduleProgress",
    # Système / analytics
    "reports", "systemConfigs", "kpis", "dashboards",
    # Messagerie
    "conversations", "conversationParticipants", "messages",
    # Divers
    "campaigns", "carts",
}


# ─────────────────────────────────────────────────────────────────────────────
# POST /execute — Exécution d'une requête MongoDB
# ─────────────────────────────────────────────────────────────────────────────
@app.route("/execute", methods=["POST"])
def execute():
    """
    Reçoit une requête MongoDB construite par db_agent et l'exécute.

    Corps JSON attendu :
    {
        "collection": "parcelles",
        "filter":     {"userId": "64abc..."},
        "projection": {"nom": 1, "surface": 1},   // optionnel
        "limit":      50                           // optionnel, défaut 50
    }

    Réponse JSON (succès) :
    {
        "status":  "ok",
        "count":   3,
        "results": [...]
    }

    Réponse JSON (erreur) :
    {
        "status": "error",
        "error":  "message"
    }
    """
    data = request.get_json(silent=True)

    if not data:
        return jsonify({"status": "error", "error": "Corps JSON manquant ou invalide."}), 400

    collection_name = data.get("collection", "").strip()
    filter_doc      = data.get("filter", {})
    projection      = data.get("projection")
    limit           = int(data.get("limit", 50))

    # ── Validation de la collection ──────────────────────────
    if not collection_name:
        return jsonify({"status": "error", "error": "Champ 'collection' manquant."}), 400

    if collection_name not in ALLOWED_COLLECTIONS:
        logger.warning("Collection refusée par le MCP server : %s", collection_name)
        return jsonify({
            "status": "error",
            "error":  f"Collection '{collection_name}' non autorisée par le MCP server."
        }), 403

    # ── Validation du filtre ─────────────────────────────────
    if not isinstance(filter_doc, dict):
        return jsonify({"status": "error", "error": "Le champ 'filter' doit être un objet JSON."}), 400

    # Sécurité : interdiction des opérateurs MongoDB dangereux
    filter_str = str(filter_doc)
    forbidden_ops = ["$where", "$function", "$accumulator", "$merge", "$out"]
    for op in forbidden_ops:
        if op in filter_str:
            logger.warning("Opérateur interdit détecté dans le filtre MCP : %s", op)
            return jsonify({
                "status": "error",
                "error":  f"Opérateur non autorisé dans le filtre : {op}"
            }), 403

    # ── Exécution de la requête MongoDB ─────────────────────
    try:
        db  = _get_client()[MONGO_DB_NAME]
        col = db[collection_name]

        cursor = col.find(filter_doc, projection).limit(limit)
        results = [_serialize_doc(doc) for doc in cursor]

        logger.info(
            "MCP exec : collection=%s filter=%s → %d résultats",
            collection_name, filter_doc, len(results)
        )

        return jsonify({
            "status":  "ok",
            "count":   len(results),
            "results": results,
        })

    except ServerSelectionTimeoutError:
        logger.error("Timeout MongoDB : collection=%s", collection_name)
        return jsonify({
            "status": "error",
            "error":  "Timeout : MongoDB est inaccessible. Vérifiez que le service est démarré."
        }), 503

    except PyMongoError as e:
        logger.error("Erreur PyMongo : %s", str(e))
        return jsonify({
            "status": "error",
            "error":  f"Erreur MongoDB : {str(e)}"
        }), 500

    except Exception as e:
        logger.error("Erreur inattendue : %s", str(e))
        return jsonify({
            "status": "error",
            "error":  f"Erreur interne du MCP server : {str(e)}"
        }), 500


# ─────────────────────────────────────────────────────────────────────────────
# GET /health — Vérification de l'état du MCP server
# ─────────────────────────────────────────────────────────────────────────────
@app.route("/health", methods=["GET"])
def health():
    """
    Endpoint de vérification de santé du MCP server.

    Réponse JSON :
    {
        "status": "ok",
        "service": "agrismart-mcp-server",
        "mongo":  "connected" | "error: ..."
    }
    """
    try:
        _get_client().admin.command("ping")
        mongo_status = "connected"
    except Exception as e:
        mongo_status = f"error: {str(e)}"

    return jsonify({
        "status":  "ok",
        "service": "agrismart-mcp-server",
        "port":    MCP_PORT,
        "mongo":   mongo_status,
    }), 200


if __name__ == "__main__":
    logger.info("Démarrage du MCP Server sur le port %d", MCP_PORT)
    app.run(host="0.0.0.0", port=MCP_PORT, debug=False)
