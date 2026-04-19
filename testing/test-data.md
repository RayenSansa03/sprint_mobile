# 📊 Données de Test - AgriSmart

## Comptes de Test Prédéfinis

### Compte Admin
```
Email: admin@agrismart.gn
Mot de passe: admin123
Rôle: ADMIN
Permissions: Accès complet
```

### Compte Utilisateur Standard
```
Email: visiteur@agrismart.gn
Mot de passe: Test@1234
Rôle: USER
Permissions: Accès utilisateur standard
```

---

## URLs des Services

| Service | URL | Port | Notes |
|---------|-----|------|-------|
| **Frontend** | http://localhost:4200 | 4200 | Angular dev server |
| **Backend** | http://localhost:8080 | 8080 | Spring Boot API |
| **Chatbot** | http://localhost:5005 | 5005 | Flask service |
| **Gateway** | http://localhost:8081 | 8081 | API Gateway |
| **MongoDB** | mongodb://localhost:27017 | 27017 | Connexion directe |

---

## Endpoints de Santé

```bash
# Backend Spring Boot
curl http://localhost:8080/actuator/health

# Chatbot Flask
curl http://localhost:5005/health

# API Gateway
curl http://localhost:8081/api/auth/health

# MongoDB (via Spring Data)
curl http://localhost:8080/actuator/db
```

---

## Scénarios de Test Courants

### Scénario 1: Authentification Admin

```bash
# 1. Request
POST /api/auth/login HTTP/1.1
Host: localhost:8081
Content-Type: application/json

{
  "email": "admin@agrismart.gn",
  "password": "admin123"
}

# 2. Expected Response (200 OK)
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "...",
    "email": "admin@agrismart.gn",
    "name": "Administrator",
    "role": "ADMIN"
  }
}

# 3. Validation
✅ Status: 200
✅ Token type: Bearer
✅ Token length: > 100 caractères
✅ User role: ADMIN
```

---

### Scénario 2: Accès Profil Utilisateur

```bash
# 1. Request
GET /api/users/profile HTTP/1.1
Host: localhost:8081
Authorization: Bearer {token}

# 2. Expected Response (200 OK)
{
  "id": "...",
  "email": "admin@agrismart.gn",
  "name": "Administrator",
  "role": "ADMIN",
  "avatar": "...",
  "createdAt": "2026-01-15T10:30:00Z"
}

# 3. Validation
✅ Status: 200
✅ Contient id, email, role
✅ Données cohérentes avec login
```

---

### Scénario 3: Créer une Ressource

```bash
# 1. Request (exemple: créer une tâche)
POST /api/tasks HTTP/1.1
Host: localhost:8081
Authorization: Bearer {token}
Content-Type: application/json

{
  "title": "Inspection des cultures",
  "description": "Vérifier l'état des plants de tomate",
  "priority": "HIGH",
  "dueDate": "2026-03-25T17:00:00Z"
}

# 2. Expected Response (201 Created)
{
  "id": "507f1f77bcf86cd799439011",
  "title": "Inspection des cultures",
  "description": "Vérifier l'état des plants de tomate",
  "priority": "HIGH",
  "status": "PENDING",
  "dueDate": "2026-03-25T17:00:00Z",
  "createdAt": "2026-03-22T10:00:00Z",
  "owner": "admin@agrismart.gn"
}

# 3. Validation
✅ Status: 201
✅ ID généré (MongoDB ObjectId)
✅ Données reflètent la requête
✅ Timestamps automatiques
```

---

### Scénario 4: Modification de Ressource

```bash
# 1. Request
PUT /api/tasks/{id} HTTP/1.1
Host: localhost:8081
Authorization: Bearer {token}
Content-Type: application/json

{
  "title": "Inspection des cultures - MISE À JOUR",
  "status": "IN_PROGRESS"
}

# 2. Expected Response (200 OK)
{
  "id": "507f1f77bcf86cd799439011",
  "title": "Inspection des cultures - MISE À JOUR",
  "status": "IN_PROGRESS",
  "updatedAt": "2026-03-22T10:05:00Z",
  ...
}

# 3. Validation
✅ Status: 200
✅ Champs modifiés mis à jour
✅ ID inchangé
✅ updatedAt nouveau
```

---

### Scénario 5: Suppression de Ressource

```bash
# 1. Request
DELETE /api/tasks/{id} HTTP/1.1
Host: localhost:8081
Authorization: Bearer {token}

# 2. Expected Response (204 No Content)
[Pas de corps]

# 3. Validation
✅ Status: 204
✅ GET {id} retourne 404 après suppression
```

---

### Scénario 6: Gestion des Erreurs

#### Erreur 400 - Données Invalides
```bash
POST /api/tasks HTTP/1.1
Host: localhost:8081
Authorization: Bearer {token}

{
  "title": "",  # Vide - invalide
  "description": "Test"
}

# Expected: 400 Bad Request
{
  "error": "Title is required",
  "timestamp": "2026-03-22T10:00:00Z"
}
```

#### Erreur 401 - Non Authentifié
```bash
GET /api/users/profile HTTP/1.1
Host: localhost:8081
# Pas de token

# Expected: 401 Unauthorized
{
  "error": "Unauthorized",
  "message": "JWT token is missing"
}
```

#### Erreur 403 - Non Autorisé
```bash
DELETE /api/users/other-user-id HTTP/1.1
Host: localhost:8081
Authorization: Bearer {user-token}

# Expected: 403 Forbidden
{
  "error": "Access Denied",
  "message": "You don't have permission to delete this user"
}
```

#### Erreur 404 - Ressource Non Trouvée
```bash
GET /api/tasks/invalid-id HTTP/1.1
Host: localhost:8081
Authorization: Bearer {token}

# Expected: 404 Not Found
{
  "error": "Task not found",
  "id": "invalid-id"
}
```

---

### Scénario 7: Chatbot

```bash
# 1. Message Simple
POST /chatbot/api/message HTTP/1.1
Host: localhost:8081
Authorization: Bearer {token}
Content-Type: application/json

{
  "message": "Quand dois-je arroser mes tomates?",
  "language": "fr"
}

# 2. Expected Response (200 OK)
{
  "response": "Les tomates doivent être arrosées régulièrement...",
  "confidence": 0.92,
  "source": "knowledge_base",
  "timestamp": "2026-03-22T10:00:00Z"
}

# 3. Validation
✅ Réponse dans la langue demandée
✅ Confidence score > 0.45
✅ Source répertoriée
```

---

## Validations par Domaine

### Frontend
- [ ] Pas d'erreurs JavaScript (F12)
- [ ] Pas de requêtes 404
- [ ] Images chargées
- [ ] Responsive (desktop, tablet, mobile)
- [ ] Multilingue fonctionne
- [ ] Localisation correcte (format date, devise)

### Backend
- [ ] Tous les endpoints 2xx/4xx retournent JSON
- [ ] Validation des données stricte
- [ ] RBAC fonctionne
- [ ] Timestamps cohérents (UTC)
- [ ] Pagination fonctionne (si applicable)

### Chatbot
- [ ] Health endpoint répond
- [ ] Requires JWT token valide
- [ ] Réponses cohérentes
- [ ] Mémoire utilisateur fonctionnelle
- [ ] Fallback si LLM down

### Database (MongoDB)
- [ ] Collections créées automatiquement
- [ ] Indices actifs
- [ ] Pas de documents orphelins
- [ ] Toutes les relations OK

---

## Headers HTTP Acceptables

```
# Request Headers
Authorization: Bearer {token}
Content-Type: application/json
Origin: http://localhost:4200
X-Requested-With: XMLHttpRequest

# Response Headers (attendus)
Access-Control-Allow-Origin: http://localhost:4200
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
Access-Control-Allow-Credentials: true
Content-Type: application/json; charset=utf-8
```

---

## Performance Baseline

| Opération | Temps attendu | Timeout |
|-----------|--------------|---------|
| Login | < 1s | 5s |
| GET Profile | < 500ms | 5s |
| GET List (50 items) | < 1s | 5s |
| POST Create | < 500ms | 5s |
| Chatbot Message | < 3s | 10s |
| TTS Generate | < 2s | 10s |

---

## Configuration pour Tests

### .env (Fichier racine)
```env
# Activer logs DEBUG
LOG_LEVEL_APP=DEBUG
CHATBOT_LOG_LEVEL=DEBUG

# Désactiver (pour tests)
CHATBOT_REQUIRE_AUTH_TOKEN=false  # Pour tester sans token
CHATBOT_REQUIRE_ADMIN_TOKEN=false
```

### Environment.ts (Frontend)
```typescript
export const environment = {
  production: false,
  apiBaseUrl: 'http://localhost:8081/api',
  chatbotApiBaseUrl: 'http://localhost:8081/chatbot',
  // OAuth keys (laisser vide en dev local)
  googleClientId: '',
  facebookAppId: ''
};
```

---

## Outils Recommandés

### Pour tester l'API
- **Postman**: GUI intuitif, collections, environnements
- **Insomnia**: Alternative légère à Postman
- **VS Code REST Client**: Plugin vs-rest-client
- **curl**: Ligne de commande simple

### Pour monitorer
- **MongoDB Compass**: GUI MongoDB
- **Spring Boot Actuator**: http://localhost:8080/actuator
- **Browser DevTools (F12)**: Network tab, Console

### Automation
- **Jest/Mocha**: Tests JS/TS
- **JUnit**: Tests Java
- **Pytest**: Tests Python
