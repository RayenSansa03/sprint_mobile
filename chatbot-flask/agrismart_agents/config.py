# ============================================================
# config.py — Configuration centrale du système multi-agents
# Charge les variables d'environnement et expose les constantes
# ============================================================

import os
from dotenv import load_dotenv

# Chargement du fichier .env à la racine du module
load_dotenv()

# ── Configuration Groq (LLM) ────────────────────────────────
# GROQ_API_KEY  : clé API Groq (https://console.groq.com)
# GROQ_MODEL    : modèle Groq à utiliser
GROQ_API_KEY = os.getenv("GROQ_API_KEY", "")
GROQ_MODEL = os.getenv("GROQ_MODEL", "llama-3.3-70b-versatile")

# Correction automatique pour les anciens modèles décommissionnés
if "llama3-70b-8192" in GROQ_MODEL:
    GROQ_MODEL = "llama-3.3-70b-versatile"

# ── Configuration MongoDB ────────────────────────────────────
MONGO_URI     = os.getenv("MONGO_URI", "mongodb://localhost:27017")
MONGO_DB_NAME = os.getenv("MONGO_DB_NAME", "agrismart")

# ── Chemins des ressources ───────────────────────────────────
# Chemin vers le vectorstore Chroma persistant
VECTORSTORE_PATH = os.getenv("VECTORSTORE_PATH", "knowledge/vectorstore_hf")

# Modèle d'embeddings local gratuit
EMBEDDING_MODEL_NAME = "sentence-transformers/all-MiniLM-L6-v2"

# Chemin vers le catalogue de navigation par rôle
CATALOG_PATH = os.getenv("CATALOG_PATH", "knowledge/providers_catalog.json")

# ── Collections autorisées par rôle ─────────────────────────
# Noms RÉELS des collections MongoDB AgriSmart (vérifiés en base de données).
ALLOWED_TABLES_BY_ROLE = {
    "agriculteur": [
        "offers",           # offres marketplace (prix publics)
        "products",         # catalogue produits marketplace
        "stocks",           # stocks de l'agriculteur
        "tasks",            # tâches planifiées
        "plans",            # plans de culture
        "planning",         # calendrier
        "campaigns",        # campagnes agricoles (participation possible)
        "supportTickets",   # tickets support
        "notifications",    # notifications
        "diseaseDetections",# diagnostics maladies
        "orders",           # commandes passées
        "orderItems",       # détail commandes
        "courses",          # formations disponibles
        "yieldPredictions", # prédictions de récolte
        "sensorReadings",   # relevés capteurs
        "sensors",          # capteurs IoT
        "plots",            # parcelles
    ],
    "cooperative": [
        "offers",
        "products",
        "stocks",
        "tasks",
        "plans",
        "planning",
        "campaigns",
        "supportTickets",
        "cooperatives",
        "cooperativeMembers",
        "cooperativePlans",
        "cooperativeReports",
        "orders",
        "notifications",
    ],
    "technicien": [
        "plots",
        "sensors",
        "sensorReadings",
        "yieldPredictions",
        "diseaseDetections",
        "supportTickets",
        "ticketMessages",
        "alerts",
        "campaigns",
    ],
    "admin": [
        "users", "roles", "permissions", "rolePermissions",
        "userSessions", "signupRequests", "roleUpgradeRequests",
        "offers", "products", "productImages", "orders", "orderItems", "payments", "stocks",
        "plots", "plans", "planning", "tasks", "taskNotifications",
        "sensors", "sensorReadings", "yieldPredictions", "diseaseDetections",
        "supportTickets", "ticketMessages",
        "campaigns",
        "cooperatives", "cooperativeMembers", "cooperativePlans", "cooperativeReports",
        "courses", "courseModules", "enrollments",
        "notifications", "alerts", "auditLogs",
        "reports", "systemConfigs", "kpis",
    ],
    "etat": [
        "offers",           # prix publics marketplace
        "products",
        "stocks",
        "campaigns",
        "reports",
        "kpis",
        "cooperatives",
    ],
    "ong": [
        "offers",
        "tasks",
        "plans",
        "planning",
        "campaigns",
        "plots",
        "supportTickets",
        "courses",
        "notifications",
    ],
    "visiteur": ["offers", "products", "productImages"],   # prix agro-marché uniquement (données publiques)
}

# ── Collections PUBLIQUES (pas de filtre utilisateur nécessaire) ─────────
# Ces collections contiennent des données accessibles à tous les rôles autorisés
# sans filtrer par identifiant utilisateur.
PUBLIC_COLLECTIONS = {
    "offers", "products", "productImages",
    "courses", "courseModules", "learningResources",
    "cooperatives", "roles", "permissions",
    "campaigns",            # campagnes visibles par tous (participation ouverte)
    "reports", "kpis", "systemConfigs",
}

# ── Champ userId réel par collection ────────────────────────────────────
# Certaines collections n'utilisent pas "userId" mais un autre champ.
# Ce mapping est utilisé par db_agent pour construire le bon filtre.
USER_FIELD_BY_COLLECTION = {
    "offers":            "ownerEmail",       # filtrer par email de l'utilisateur
    "stocks":            "sellerUserId",
    "products":          "sellerUserId",
    "supportTickets":    "createdByUserId",
    "orders":            "buyerUserId",
    "orderItems":        "orderId",          # pas de userId direct
    "payments":          "buyerUserId",
    "diseaseDetections": "userId",
    "yieldPredictions":  "userId",
    "sensorReadings":    "userId",
    "sensors":           "userId",
    "plots":             "userId",
    "tasks":             "ownerEmail",       # filtrer par email du propriétaire (champ réel)
    "plans":             "userId",
    "planning":          "userId",
    "notifications":     "userId",
    "enrollments":       "userId",
    "cooperativeMembers":"userId",
    "users":             "_id",              # exception : filtrer par _id
}

# ── Mapping sémantique : alias utilisateur → nom de collection réel ──────
COLLECTION_ALIASES = {
    # Marketplace / offres
    "prix": "offers", "tarifs": "offers", "offres": "offers",
    "marketplace": "offers", "marché": "offers", "marche": "offers",
    "produits": "products", "catalogue": "products",
    # Commandes
    "commandes": "orders", "commande": "orders",
    "paiements": "payments",
    # Agriculture
    "parcelles": "plots", "parcelle": "plots", "terrain": "plots",
    "cultures": "plans", "planification": "planning",
    "tâches": "tasks", "taches": "tasks",
    "récoltes": "yieldPredictions", "recoltes": "yieldPredictions",
    "prédictions": "yieldPredictions",
    # IoT / capteurs
    "capteurs": "sensors", "capteur": "sensors", "iot": "sensors",
    "relevés": "sensorReadings", "lectures": "sensorReadings",
    # Support / alertes
    "tickets": "supportTickets", "ticket": "supportTickets", "support": "supportTickets",
    "alertes": "alerts", "alerte": "alerts",
    # Diagnostic
    "diagnostics": "diseaseDetections", "maladies": "diseaseDetections",
    "diagnostic": "diseaseDetections",
    # Formation
    "formations": "courses", "cours": "courses", "formation": "courses",
    # Notifications
    "notifications": "notifications",
    # Utilisateurs
    "utilisateurs": "users",
    # Campagnes agricoles
    "campagnes": "campaigns", "campagne": "campaigns",
    "campagnes actives": "campaigns",
    # Cooperatives
    "coopératives": "cooperatives", "cooperatives": "cooperatives",
}

# ── Champs sensibles à exclure des réponses utilisateur ─────────────────
SENSITIVE_FIELDS = {
    "email", "ownerEmail", "passwordHash", "password", "token", "refreshToken",
    "accessToken", "secret", "apiKey",
}

# ── Schéma MongoDB RÉEL (vérifié en base de données) ────────────────────
DB_SCHEMA_STR = """
COLLECTIONS RÉELLES MONGODB AGRISMART :

MARKETPLACE
- offers:        {_id, product, quantity, unit, price, quality, availability,
                  status, ownerEmail, date, adminWarning, suggestedPrice}
                  ← DONNÉES PUBLIQUES — ne pas filtrer par utilisateur
                  ← Pour les prix d'un produit spécifique : filter {"product": "<nom>"}
- products:      {_id, sellerUserId, name, category, description, unit, unitPrice,
                  stockQty, status, createdAt, updatedAt}
- stocks:        {_id, sellerUserId, productId, productName, unit, totalQuantity,
                  reservedQuantity, soldQuantity, availableQuantity, minimumThreshold, status}
- orders:        {_id, buyerUserId, sellerUserId, productId, quantity, totalPrice, status, createdAt}
- orderItems:    {_id, orderId, productId, quantity, unitPrice}
- payments:      {_id, orderId, buyerUserId, amount, method, status, paidAt}

AGRICULTURE
- plots:         {_id, userId, name, areaHa, cropType, location, createdAt}
- plans:         {_id, userId, plotId, title, season, cropType, startDate, endDate}
- planning:      {_id, userId, plotId, planId, scheduledDate, activityType, notes}
- tasks:         {_id, planId, plotId, title, description, type, taskType, parcel,
                  status, priority, date, dueDate, ownerEmail, assignedTo,
                  assignedToUserId, notes, createdAt, completedAt}
                  ← filtrer par ownerEmail (email de l'agriculteur propriétaire)
                  ← Pour les tâches futures : filter {"dueDate": {"$gte": today}}
                  ← Pour les tâches par statut : filter {"status": "pending"}
- yieldPredictions: {_id, userId, plotId, predictedYieldKg, confidence, predictedAt}

CAMPAGNES AGRICOLES
- campaigns:     {_id, name, zone, description, startDate, endDate, status,
                  participants, createdByEmail, creatorFirstName, creatorLastName,
                  createdAt, updatedAt}
                  ← DONNÉES PUBLIQUES — ne pas filtrer par utilisateur
                  ← status possible : "active", "planned", "completed", "cancelled"
                  ← Pour campagnes actives : filter {"status": "active"}
                  ← Pour campagnes futures : filter {"status": "planned"}

IOT / CAPTEURS
- sensors:       {_id, userId, plotId, type, model, installedAt, active}
- sensorReadings:{_id, sensorId, userId, plotId, value, unit, timestamp, alertLevel}
- diseaseDetections:{_id, userId, imageUrl, disease, confidence, detectedAt}

SUPPORT
- supportTickets:{_id, createdByUserId, category, subject, description,
                  priority, status, assignedToUserId, createdAt}
- ticketMessages:{_id, ticketId, senderId, content, sentAt}
- alerts:        {_id, title, message, severity, target, createdBy, createdAt, resolved}
- notifications: {_id, userId, title, message, type, read, createdAt}

COOPERATIVE
- cooperatives:       {_id, name, region, description, createdAt}
- cooperativeMembers: {_id, userId, cooperativeId, role, joinedAt}
- cooperativePlans:   {_id, cooperativeId, title, season, details}
- cooperativeReports: {_id, cooperativeId, title, content, createdAt}

FORMATION
- courses:       {_id, title, description, instructorName, image, tag, chapters}
- courseModules: {_id, courseId, title, content, order}
- enrollments:   {_id, userId, courseId, enrolledAt, completedAt, progress}

AUTH / UTILISATEURS
- users:         {_id, email, firstName, lastName, roleId, organization, status, createdAt}
                  ← filtrer par "_id" (pas "userId")
- roles:         {_id, name, description}
- permissions:   {_id, name, resource, action}

SYSTÈME
- reports:       {_id, type, generatedAt, data}
- kpis:          {_id, metric, value, period, createdAt}
- systemConfigs: {_id, key, value, updatedAt}
- auditLogs:     {_id, userId, action, resource, timestamp}

RÈGLES DE FILTRAGE :
- Collections PUBLIC (offers, products, courses, cooperatives) → filter: {}
  ou filter par mot-clé (ex: {product: "Tomates"} pour chercher un produit)
- Collections PRIVÉES → utiliser le champ userId propre à chaque collection
  (voir USER_FIELD_BY_COLLECTION dans config.py)
""".strip()


def get_llm():
    """
    Retourne l'instance LLM LangChain configurée sur Groq.

    Modèle par défaut : llama3-70b-8192 (excellent rapport performance/vitesse).
    Pour changer de modèle, définir GROQ_MODEL dans .env :
        GROQ_MODEL=mixtral-8x7b-32768
        GROQ_MODEL=llama3-8b-8192  (plus rapide, moins précis)

    La température est fixée à 0.2 pour des réponses cohérentes et reproductibles.
    """
    from langchain_groq import ChatGroq
    return ChatGroq(
        api_key=GROQ_API_KEY,
        model=GROQ_MODEL,
        temperature=0.2,
    )
