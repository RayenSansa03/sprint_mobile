# 🤖 Documentation Chatbot AgriSmart

## Vue d'ensemble simple

Le chatbot AgriSmart est un assistant intelligent qui répond aux questions des agriculteurs en utilisant l'intelligence artificielle. Il écoute votre question, décide quel type d'aide vous proposer, puis vous donne la meilleure réponse.

---

## Comment ça fonctionne ? 

### 1️⃣ **Vous posez une question**
L'utilisateur envoie un message au chatbot via l'application web Angular.

```
Utilisateur: "Comment traiter la rouille sur mes plants?"
```

### 2️⃣ **Le routeur classe votre question**
Le **router_agent** lit votre question et décide quel type de réponse vous donner:

| Type | Exemple | Action |
|------|---------|--------|
| **guide_ui** | "Comment créer un profil?" | → Recherche dans les guides d'utilisation |
| **query_db** | "Quels sont mes champs?" | → Récupère les données de la base de données |
| **info_agri** | "Quelles cultures pour mon climat?" | → Donne des informations agricoles |
| **fallback** | Question non classée | → Donne une réponse générale |

### 3️⃣ **Traitement selon le type**

#### 🔹 Si c'est une **question de guide** (guide_ui)
- Utilise **FAISS** (moteur de recherche intelligent)
- Cherche dans les documents de connaissance
- Utilise **Groq LLM** pour formater la réponse
- Envoie la réponse formatée

#### 🔹 Si c'est une **requête de données** (query_db)
- Construit un filtre MongoDB automatiquement
- Envoie la requête au **MCP Server** (port 5001)
- Le MCP Server récupère les données de MongoDB
- Formate et envoie les données

#### 🔹 Si c'est une **info agricole** (info_agri)
- Utilise la connaissance générale du LLM
- Donne une réponse basée sur l'expertise agricole
- Formule la réponse simplement

### 4️⃣ **Vous recevez la réponse**
À la fin, le chatbot envoie la réponse formatée à l'utilisateur.

```
Chatbot: "La rouille se traite avec... Voici les étapes..."
```

---

## Architecture technique (simple)

```
┌─────────────────────┐
│  Application Web    │
│     (Angular)       │
└──────────┬──────────┘
           │ POST /chat
           │ (votre question)
           ▼
┌──────────────────────────────────┐
│   Chatbot LangGraph (Port 5002)  │
│                                  │
│  1. router_agent (classe)        │
│     ↓                            │
│  2. guide_node OU                │
│     db_agent_node OU             │
│     info_node                    │
│     ↓                            │
│  3. answer_db_agent (formate)    │
└──────────┬───────────────────────┘
           │
           ├─→ (RAG: cherche docs) ──→ Groq LLM
           │
           └─→ (DB: requête) ──→ MCP Server (Port 5001) ──→ MongoDB
                                  │
                                  └─→ Execute() MongoDB
```

---

## Composants principaux

### 📌 **router_agent**
- **Rôle** : Classe l'intention de l'utilisateur
- **Entrée** : Votre question + votre rôle (agriculteur, admin, etc.)
- **Sortie** : Type de question identifiée

### 📌 **guide_node** (Répondeur de guides)
- **Rôle** : Répond aux questions d'utilisation
- **Exemple** : "Comment démarrer?" → Envoie les guides

### 📌 **db_agent_node** (Requête base de données)
- **Rôle** : Récupère vos données personnelles
- **Exemple** : "Mes champs" → Va chercher dans MongoDB

### 📌 **info_node** (Info agricole)
- **Rôle** : Donne des conseils agricoles
- **Exemple** : "Comment cultiver tomates?" → Conseil agricole

### 📌 **answer_db_agent**
- **Rôle** : Formate la réponse finale
- **Sortie** : Réponse lisible pour l'utilisateur

### 📌 **MCP Server** (Port 5001)
- **Rôle** : Exécute les requêtes MongoDB
- **Entrée** : Filtre MongoDB
- **Sortie** : Données récupérées

---

## Flux complet (exemple)

### Scénario : "Quels sont mes champs?"

```
1️⃣  Utilisateur envoie: "Quels sont mes champs?"

2️⃣  router_agent analyse
    → Détecte: "query_db" (requête de données)

3️⃣  db_agent_node crée automatiquement:
    Filtre MongoDB: { owner_email: "user@email.com" }

4️⃣  mcp_tool_node envoie:
    POST http://localhost:5001/execute
    Avec: { filtre MongoDB }

5️⃣  MCP Server:
    → Va chercher dans MongoDB
    → Retourne: [Champ 1, Champ 2, Champ 3, ...]

6️⃣  answer_db_agent formate:
    "Vous avez 3 champs:
     • Champ blé (10 hectares)
     • Champ maïs (5 hectares)  
     • Champ légumes (2 hectares)"

7️⃣  Utilisateur reçoit la réponse formatée
```

---

## Flux complet (exemple 2)

### Scénario : "Comment traiter la rouille?"

```
1️⃣  Utilisateur envoie: "Comment traiter la rouille?"

2️⃣  router_agent analyse
    → Détecte: "info_agri" (info agricole)

3️⃣  info_node consulte:
    → Base de connaissances FAISS
    → Groq LLM intelligent

4️⃣  Réponse générée:
    "La rouille se traite par:
     • Pulvérisation de fongicide
     • Aération du champ
     • Rotation des cultures"

5️⃣  Utilisateur reçoit la réponse
```

---

## Environnement & Configuration

### Variables nécessaires (.env)

```
# Clé API Groq (gratuit sur https://console.groq.com)
GROQ_API_KEY=xxxxx

# URL de l'app Angular
ANGULAR_URL=http://localhost:4200

# Clé API pour l'ingestion de données
INGEST_API_KEY=secret_key
```

### Ports
- **Chatbot** : Port 5002 (`/chat`)
- **MCP Server** : Port 5001 (`/execute`)

---

## Démarrage simple

```powershell
# 1. Aller à la racine du projet
cd c:\Users\Youssefh\Desktop\youssef\SprintWeb

# 2. Lancer le chatbot
python chatbot-flask/agrismart_agents/app.py

# 3. Dans un autre terminal, lancer le MCP Server
python chatbot-flask/mcp_server/app.py

# 4. Ouvrir http://localhost:4200 dans l'app Angular
```

---

## Résumé en 3 phrases

1. **Vous posez une question** au chatbot
2. **Le router classe votre question** (guide? données? info?)
3. **Le chatbot vous donne la meilleure réponse** en utilisant IA + données

Voilà! 🎉
