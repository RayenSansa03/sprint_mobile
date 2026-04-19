# Chatbot Flask — AgriSmart

Microservice Python/Flask multi-agents pour guider les utilisateurs de la plateforme AgriSmart.

## Architecture

Deux processus Flask distincts :

| Processus | Répertoire | Port | Rôle |
|-----------|-----------|------|------|
| **Chatbot LangGraph** | `agrismart_agents/` | 5002 | Orchestration multi-agents, endpoint `/chat` |
| **MCP Server** | `mcp_server/` | 5001 | Exécuteur de requêtes MongoDB |

```
Angular / API Gateway
    └─→ POST /chat  (agrismart_agents/app.py : 5002)
              └─→ LangGraph : routing_agent → rag_agent / db_agent → answer_agent
                                                        └─→ POST /execute (mcp_server/app.py : 5001)
                                                                  └─→ MongoDB
```

### Agents LangGraph

| Agent | Rôle |
|-------|------|
| `routing_agent` | Classifie l'intention : `guidance` (RAG) ou `query_db` (MongoDB) |
| `rag_agent` | Retrieval FAISS + génération Groq LLM |
| `db_agent` | Construit un filtre MongoDB et l'envoie au MCP server |
| `answer_agent` | Formate la réponse finale |

## Installation (une seule fois)

Le venv est partagé à la racine du dépôt :

```powershell
# Depuis la racine du dépôt (Agrismart/)
python -m venv .venv-1
.venv-1\Scripts\Activate.ps1
pip install -r chatbot-flask\requirements.txt
```

## Configuration

Les variables sont lues depuis le fichier `.env` à la racine du dépôt (`Agrismart/.env`).

Variables essentielles pour le chatbot :

| Variable | Description | Défaut |
|----------|-------------|--------|
| `GROQ_API_KEY` | Clé API Groq (https://console.groq.com) | *(obligatoire)* |
| `GROQ_MODEL` | Modèle LLM | `llama-3.3-70b-versatile` |
| `MONGO_URI` | URI MongoDB | `mongodb://localhost:27017` |
| `MONGO_DB_NAME` | Base MongoDB | `agrismart` |
| `JWT_SECRET` | Partagé avec Spring Boot | *(obligatoire si auth active)* |
| `JWT_ALGORITHM` | Algorithme JWT | `HS256` |
| `FLASK_PORT` | Port du chatbot | `5002` |
| `MCP_SERVER_PORT` | Port du MCP server | `5001` |
| `INGEST_API_KEY` | Protection endpoint `/ingest` | `secret_ingest_key` |
| `ANGULAR_URL` | Origine CORS Angular | `http://localhost:4200` |

## Lancement

### Via le script racine (recommandé)

```powershell
# Depuis Agrismart/
powershell -ExecutionPolicy Bypass -File .\start-all.ps1
```

### Manuel

```powershell
# Activer le venv
.venv-1\Scripts\Activate.ps1

# Terminal 1 — MCP Server (doit démarrer en premier)
cd chatbot-flask\mcp_server
python app.py

# Terminal 2 — Chatbot LangGraph
cd chatbot-flask\agrismart_agents
python app.py
```

## Endpoints

### `POST /chat` — Message utilisateur

```json
{
  "message": "Quelles sont mes parcelles ?",
  "email": "user@agrismart.gn",
  "role": "agriculteur",
  "lang": "fr",
  "session_id": "optional-session-id"
}
```

Réponse :

```json
{
  "reply": "Vous avez 3 parcelles enregistrées...",
  "intent": "query_db",
  "session_id": "...",
  "status": "ok"
}
```

### `GET /health` — État du service

```json
{
  "status": "ok",
  "groq": "configured",
  "mongodb": "connected",
  "graph": "ready"
}
```

### `POST /ingest` — Ingestion de documents RAG

Protégé par `X-API-Key: <INGEST_API_KEY>`.

## Tests E2E

```powershell
# Depuis chatbot-flask/ (tous les services doivent être démarrés)
powershell -ExecutionPolicy Bypass -File .\test_e2e.ps1
```

Résultat attendu : `PASS=8 FAIL=0 SKIP=0`

## Structure

```
chatbot-flask/
├── agrismart_agents/       ← Chatbot Flask (port 5002)
│   ├── app.py              ← Point d'entrée Flask
│   ├── config.py           ← Variables d'environnement
│   ├── state.py            ← État LangGraph (AgriSmartState)
│   ├── graph/
│   │   └── graph_builder.py  ← Construction du graphe LangGraph
│   ├── agents/             ← routing, rag, db, answer agents
│   ├── tools/
│   │   ├── mongo_tool.py   ← Connexion MongoDB directe
│   │   └── mcp_tool.py     ← Bridge HTTP → MCP server
│   └── knowledge/          ← Vectorstore FAISS + catalog JSON
├── mcp_server/
│   └── app.py              ← MCP Server Flask (port 5001)
├── knowledge_sources/      ← Documents source pour le RAG
├── requirements.txt
├── test_e2e.ps1
└── README.md
```
