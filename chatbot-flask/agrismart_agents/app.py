# ============================================================
# app.py — Point d'entrée Flask du système multi-agents AgriSmart
# Pont entre Spring Boot et le graphe LangGraph.
# Endpoints : POST /chat | GET /health | POST /ingest
# ============================================================

import os
import sys
import functools

from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv

# Chargement des variables d'environnement depuis .env
load_dotenv()

# Ajout du répertoire du module au sys.path pour les imports absolus
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from graph.graph_builder import build_graph
from tools.mongo_tool import check_connection, get_user_id_from_email

# ── Création de l'application Flask ─────────────────────────
app = Flask(__name__)

# ── CORS : autoriser l'origine Angular et le Gateway ────────
ANGULAR_URL = os.getenv("ANGULAR_URL", "http://localhost:4200")
CORS(app, resources={r"/*": {"origins": "*"}})

# ── Clé API pour l'endpoint /ingest ─────────────────────────
INGEST_API_KEY = os.getenv("INGEST_API_KEY", "secret_ingest_key")

# ── Initialisation du graphe LangGraph ──────────────────────
# Le graphe est compilé une seule fois au démarrage pour éviter la surcharge.
print("[AgriSmart] Initialisation du graphe multi-agents LangGraph...")
graph = build_graph()
print("[AgriSmart] Graphe compilé et prêt.")

# Rôles utilisateur valides dans AgriSmart
VALID_ROLES = {"visiteur", "admin", "agriculteur", "cooperative", "etat", "technicien", "ong"}

# Mapping des rôles Spring Boot → rôles agents Flask
ROLE_MAP = {
    "PRODUCTEUR":  "agriculteur",
    "COOPERATIVE": "cooperative",
    "TECHNICIEN":  "technicien",
    "ONG":         "ong",
    "ETAT":        "etat",
    "ADMIN":       "admin",
    "VIEWER":      "visiteur",
    # Versions lowercase déjà acceptées
    "producteur":  "agriculteur",
    "cooperative": "cooperative",
    "technicien":  "technicien",
    "ong":         "ong",
    "etat":        "etat",
    "admin":       "admin",
    "viewer":      "visiteur",
}


def normalize_role(role: str) -> str:
    """
    Normalise le rôle Spring Boot (PRODUCTEUR, VIEWER...) vers le rôle agent
    (agriculteur, visiteur...). Retourne 'visiteur' si le rôle est inconnu.
    """
    if not role:
        return "visiteur"
    normalized = ROLE_MAP.get(role.strip(), role.strip().lower())
    return normalized if normalized in VALID_ROLES else "visiteur"


def require_ingest_key(f):
    """Décorateur de protection par X-API-KEY pour l'endpoint /ingest."""
    @functools.wraps(f)
    def decorated(*args, **kwargs):
        key = request.headers.get("X-API-KEY", "")
        if key != INGEST_API_KEY:
            return jsonify({"error": "Clé API invalide ou absente."}), 403
        return f(*args, **kwargs)
    return decorated


# ─────────────────────────────────────────────────────────────────────────────
# POST /chat — Endpoint principal du chatbot multi-agents
# ─────────────────────────────────────────────────────────────────────────────
@app.route("/chat", methods=["POST"])
def chat():
    """
    Réponse JSON :
    {
        "response":        "...",
        "intent":          "guide_ui | query_db | info_agri | unknown",
        "suggested_pages": [...],
        "diagnostic_context": "...", // Echoed context
        "error":           null
    }
    """
    from tools.mongo_tool import get_chat_history, save_chat_message
    data = request.get_json(silent=True)

    if not data:
        return jsonify({"error": "Corps de requête JSON manquant ou invalide."}), 400

    # ── Lecture et validation des champs obligatoires ────────
    # user_id contient en réalité l'EMAIL de l'utilisateur,
    # tel que Spring Boot l'a extrait du claim 'sub' du JWT.
    email_received = (data.get("user_id") or "").strip()
    user_role      = normalize_role(data.get("user_role") or "visiteur")
    query          = (data.get("query") or "").strip()
    diagnostic     = (data.get("diagnostic_context") or "").strip()

    if not email_received:
        return jsonify({"error": "Champ 'user_id' (email) manquant ou vide."}), 400

    if not query:
        return jsonify({"error": "Champ 'query' manquant ou vide."}), 400

    # ── Sauvegarde du message utilisateur ────────────────────
    save_chat_message(email_received, "user", query, diagnostic if diagnostic else None)

    # ── Récupération de l'historique ─────────────────────────
    history = get_chat_history(email_received)

    # ── Résolution email → userId MongoDB ────────────────────
    resolved_user_id = get_user_id_from_email(email_received)

    if resolved_user_id is None:
        return jsonify({
            "error": f"Utilisateur introuvable pour l'email '{email_received}'."
        }), 404

    # ── Construction de l'état initial ───────────────────────
    # À partir d'ici, user_id est le VRAI identifiant MongoDB (ObjectId en str).
    # db_agent utilisera cet id pour filtrer : {"userId": resolved_user_id}
    # mcp_tool_node enverra ensuite la requête au MCP server (port 5001).
    initial_state = {
        "user_id":        resolved_user_id,
        "user_email":     email_received,
        "user_role":      user_role,
        "user_query":     query,
        "diagnostic_context": diagnostic, # Champ étendu
        "intent":         "",
        "mongo_query":    None,
        "mongo_result":   None,
        "final_response": "",
        "error":          None,
        "conversation_history": history,
    }

    try:
        final_state = graph.invoke(initial_state)
        response_text = final_state.get("final_response", "")

        # ── Sauvegarde de la réponse assistant ────────────────────
        save_chat_message(email_received, "assistant", response_text)

        suggested_pages = _extract_suggested_pages(
            response_text,
            final_state.get("intent", ""),
        )

        return jsonify({
            "response":        final_state.get("final_response", ""),
            "intent":          final_state.get("intent", "unknown"),
            "suggested_pages": suggested_pages,
            "error":           final_state.get("error"),
        })

    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({
            "response":        "Une erreur interne s'est produite. Veuillez réessayer.",
            "intent":          "unknown",
            "suggested_pages": [],
            "error":           str(e),
        }), 500


def _extract_suggested_pages(response_text: str, intent: str) -> list:
    """
    Extrait les URLs mentionnées dans la réponse du chatbot.
    Retourne une liste de chemins commençant par '/' (max 5).
    """
    import re
    if intent != "guide_ui" or not response_text:
        return []

    pattern = r'(/(?:app/)?[a-z0-9\-/]+)'
    matches = re.findall(pattern, response_text)

    seen = set()
    pages = []
    for m in matches:
        if m not in seen and len(m) > 1:
            seen.add(m)
            pages.append(m)
    return pages[:5]


# ─────────────────────────────────────────────────────────────────────────────
# POST /visitor-chat — Endpoint public pour les visiteurs non authentifiés
# Appel direct Angular → Flask (sans passer par le gateway Spring Boot)
# ─────────────────────────────────────────────────────────────────────────────
@app.route("/visitor-chat", methods=["POST"])
def visitor_chat():
    """
    Corps JSON attendu :
    {
        "query": "Qu'est-ce que le mildiou ?",
        "lang":  "fr"                    // optionnel, défaut "fr"
    }

    Le visiteur n'a pas de compte. Seules les intentions info_agri et guide_ui
    sont autorisées (query_db est bloquée dans graph_builder._route_intent).

    Réponse JSON :
    {
        "response":        "...",
        "intent":          "info_agri | guide_ui | unknown",
        "suggested_pages": [...],
        "error":           null
    }
    """
    data = request.get_json(silent=True)

    if not data:
        return jsonify({"error": "Corps de requête JSON manquant ou invalide."}), 400

    query = data.get("query", "").strip()
    lang  = data.get("lang", "fr")

    if not query:
        return jsonify({"error": "Champ 'query' manquant ou vide."}), 400

    # Le visiteur est traité comme un utilisateur anonyme — pas de lookup MongoDB
    initial_state = {
        "user_id":        "anonymous",
        "user_email":     "visitor@agrismart.app",
        "user_role":      "visiteur",
        "user_query":     query,
        "intent":         "",
        "mongo_query":    None,
        "mongo_result":   None,
        "final_response": "",
        "error":          None,
    }

    try:
        final_state = graph.invoke(initial_state)

        suggested_pages = _extract_suggested_pages(
            final_state.get("final_response", ""),
            final_state.get("intent", ""),
        )

        return jsonify({
            "response":        final_state.get("final_response", ""),
            "intent":          final_state.get("intent", "unknown"),
            "suggested_pages": suggested_pages,
            "error":           final_state.get("error"),
        })

    except Exception as e:
        return jsonify({
            "response":        "Le service est momentanément indisponible. Veuillez réessayer.",
            "intent":          "unknown",
            "suggested_pages": [],
            "error":           str(e),
        }), 500


# ─────────────────────────────────────────────────────────────────────────────
# GET /health — Vérification de l'état du service
# ─────────────────────────────────────────────────────────────────────────────
@app.route("/health", methods=["GET"])
def health():
    """
    Retourne l'état de santé du service Flask et de ses dépendances.

    Réponse JSON :
    {
        "status": "ok",
        "mongo":  "connected" | "error: ...",
        "groq":   "configured" | "not configured"
    }
    """
    mongo_status  = check_connection()
    mongo_display = (
        "connected" if mongo_status["status"] == "connected"
        else f"error: {mongo_status.get('message', 'unknown')}"
    )

    groq_key     = os.getenv("GROQ_API_KEY", "")
    groq_display = "configured" if groq_key else "not configured"

    mcp_url = os.getenv("MCP_SERVER_URL", "http://localhost:5001/execute")

    return jsonify({
        "status":         "ok",
        "service":        "agrismart-multi-agents",
        "mongo":          mongo_display,
        "groq":           groq_display,
        "mcp_server_url": mcp_url,
    }), 200


# ─────────────────────────────────────────────────────────────────────────────
# POST /ingest — Ingestion de documents dans la base vectorielle Chroma
# Protégé par X-API-KEY header
# ─────────────────────────────────────────────────────────────────────────────
@app.route("/ingest", methods=["POST"])
@require_ingest_key
def ingest():
    """
    Ingère des documents dans le vectorstore Chroma persistant.

    Corps JSON attendu :
    {
        "texts":     ["texte1", "texte2", ...],
        "metadatas": [{"source": "..."}, ...]
    }

    Réponse JSON :
    {
        "ingested": <nombre>,
        "error":    null
    }
    """
    data = request.get_json(silent=True)
    if not data:
        return jsonify({"error": "Corps JSON manquant."}), 400

    texts     = data.get("texts", [])
    metadatas = data.get("metadatas", [])

    if not texts or not isinstance(texts, list):
        return jsonify({"error": "Champ 'texts' manquant ou invalide."}), 400

    if not metadatas or len(metadatas) != len(texts):
        metadatas = [{"source": "api-ingest"}] * len(texts)

    try:
        from langchain_community.vectorstores import Chroma
        from langchain_huggingface import HuggingFaceEmbeddings
        from config import VECTORSTORE_PATH, EMBEDDING_MODEL_NAME

        base_dir = os.path.dirname(os.path.abspath(__file__))
        vs_path  = os.path.join(base_dir, VECTORSTORE_PATH)
        os.makedirs(vs_path, exist_ok=True)

        embedding_fn = HuggingFaceEmbeddings(model_name=EMBEDDING_MODEL_NAME)
        vectorstore  = Chroma(
            persist_directory=vs_path,
            embedding_function=embedding_fn,
        )

        from langchain_core.documents import Document
        docs = [
            Document(page_content=text, metadata=meta)
            for text, meta in zip(texts, metadatas)
        ]

        vectorstore.add_documents(docs)
        return jsonify({"ingested": len(docs), "error": None})

    except Exception as e:
        return jsonify({"ingested": 0, "error": str(e)}), 500


if __name__ == "__main__":
    port = int(os.getenv("FLASK_PORT", 5002))
    app.run(host="0.0.0.0", port=port, debug=False)
