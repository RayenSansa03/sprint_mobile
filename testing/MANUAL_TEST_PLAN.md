# 📋 Plan de Test Manuel - AgriSmart

## Comptes de Test

**Admin:**
- Email: `admin@agrismart.gn`
- Mot de passe: `admin123`

**Utilisateur Standard:**
- Email: `visiteur@agrismart.gn`
- Mot de passe: `Test@1234`

---

## ✅ 1. Tests de Démarrage

### Vérification Services
- [ ] MongoDB actif (port 27017)
- [ ] Backend Spring Boot (port 8080) - http://localhost:8080/actuator/health
- [ ] Chatbot Flask (port 5005) - http://localhost:5005/health
- [ ] API Gateway (port 8081) - http://localhost:8081/api/auth/health
- [ ] Frontend Angular (port 4200) - http://localhost:4200

```powershell
# Exécuter dans PowerShell:
Invoke-RestMethod -Uri "http://localhost:8080/actuator/health"
Invoke-RestMethod -Uri "http://localhost:5005/health"
Invoke-RestMethod -Uri "http://localhost:8081/api/auth/health"
```

---

## 🔐 2. Tests d'Authentification

### 2.1 Login via Interface Web
- [ ] Accéder à http://localhost:4200
- [ ] Page de login affichée
- [ ] Se connecter avec admin@agrismart.gn / admin123
- [ ] Redirection vers dashboard après login succès
- [ ] Token JWT stocké dans localStorage/sessionStorage
- [ ] Logout fonctionne et nettoie les tokens

### 2.2 Login via API (Postman/Curl)
```bash
POST http://localhost:8081/api/auth/login
Content-Type: application/json

{
  "email": "admin@agrismart.gn",
  "password": "admin123"
}
```
- [ ] Status 200 reçu
- [ ] Réponse contient `token` ou `accessToken`
- [ ] Réponse contient user data (id, email, role)

### 2.3 Refresh Token
```bash
POST http://localhost:8081/api/auth/refresh
Authorization: Bearer {accessToken}
```
- [ ] Nouveau token généré
- [ ] Status 200
- [ ] Ancien token reste valide temporairement

### 2.4 JWT Validation
- [ ] Requête sans token → 401 Unauthorized
- [ ] Requête avec token expiré → 401
- [ ] Requête avec token invalide → 401

---

## 🎯 3. Tests Frontend - Interface Utilisateur

### 3.1 Navigation
- [ ] Barre de navigation visible
- [ ] Liens actifs/inactifs selon les droits
- [ ] Menu déroulant utilisateur présent

### 3.2 Multilingue (i18n)
- [ ] Sélecteur de langue visible
- [ ] Texte change lors du changement de langue
- [ ] Langues supportées : [Ajouter les vôtres]

### 3.3 Layout Principal
- [ ] Header présent
- [ ] Sidebar/Menu latéral fonctionne
- [ ] Footer visible
- [ ] Responsive Design OK (tester sur mobile)

### 3.4 Pages Critiques
- [ ] Dashboard page charge
- [ ] Aucune erreur JavaScript (F12 console)
- [ ] Images/assets chargées correctement
- [ ] Pas de requêtes 404

---

## 🔗 4. Tests API Backend

### 4.1 Santé et Info
```bash
GET http://localhost:8080/actuator/health
GET http://localhost:8080/actuator/info
```
- [ ] Status UP
- [ ] MongoDB connectée

### 4.2 Utilisateurs
```bash
# Récupérer profil
GET http://localhost:8081/api/users/profile
Authorization: Bearer {token}
```
- [ ] Status 200
- [ ] Données utilisateur correctes (email, nom, role)

### 4.3 Tâches (exemple)
```bash
# Lister les tâches
GET http://localhost:8081/api/tasks
Authorization: Bearer {token}

# Créer une tâche
POST http://localhost:8081/api/tasks
Authorization: Bearer {token}
Content-Type: application/json

{
  "title": "Test Task",
  "description": "Cette tâche est créée pour tester"
}

# Récupérer une tâche
GET http://localhost:8081/api/tasks/{id}
Authorization: Bearer {token}

# Mettre à jour une tâche
PUT http://localhost:8081/api/tasks/{id}
Authorization: Bearer {token}

# Supprimer une tâche
DELETE http://localhost:8081/api/tasks/{id}
Authorization: Bearer {token}
```

**Tests:**
- [ ] GET → Status 200, tableau reçu
- [ ] POST → Status 201, objet créé avec ID
- [ ] PUT → Status 200, modifications appliquées
- [ ] DELETE → Status 204, objet supprimé

### 4.4 Validations
- [ ] Données invalides → Status 400 avec message d'erreur
- [ ] Ressource inexistante → Status 404
- [ ] Accès non autorisé → Status 403
- [ ] Erreur serveur → Status 500 loggée

---

## 🤖 5. Tests Chatbot (Flask)

### 5.1 Health Check
```bash
GET http://localhost:5005/health
```
- [ ] Status 200
- [ ] Flask running OK

### 5.2 Authentification Chatbot
```bash
POST http://localhost:8081/chatbot/api/message
Authorization: Bearer {jwt_token}
Content-Type: application/json

{
  "message": "Bonjour"
}
```
- [ ] Requête sans token → 401
- [ ] Requête avec token valide → 200
- [ ] Réponse en JSON

### 5.3 Message et Réponse
- [ ] Message envoyé → Status 200
- [ ] Réponse AI reçue (si LLM configurée)
- [ ] Fallback response si pas de LLM
- [ ] Historique conservé (selon config)

### 5.4 TTS (Text-to-Speech)
```bash
POST http://localhost:8081/chatbot/api/tts
Authorization: Bearer {jwt_token}
Content-Type: application/json

{
  "text": "Bonjour agriculteur"
}
```
- [ ] Audio générée (blob/url)
- [ ] Format audio OK (MP3, WAV, etc.)

### 5.5 Admin Endpoints
```bash
POST http://localhost:5005/admin/clear-memory
X-Admin-Token: admin-token-test-123456
```
- [ ] Requête sans token → 401
- [ ] Requête avec token → 200
- [ ] Mémoire chatbot clearée

---

## 🌐 6. Tests API Gateway

### 6.1 Routing
- [ ] `/api/**` → Routé vers Spring Boot (8080)
- [ ] `/chatbot/**` → Routé vers Flask (5005)

### 6.2 CORS
```bash
OPTIONS http://localhost:8081/api/auth/login
Origin: http://localhost:4200
```
- [ ] CORS headers présents
- [ ] Access-Control-Allow-Origin: http://localhost:4200
- [ ] Access-Control-Allow-Methods: GET, POST, PUT, DELETE

### 6.3 JWT Validation Gateway
- [ ] Token frontend validé avant routage
- [ ] Token invalide → erreur gateway
- [ ] Routes publiques (login) ne demandent pas token

### 6.4 Rate Limiting (si configuré)
- [ ] Requêtes multiples rapides → Status 429 après limite
- [ ] Limite reset après temps configuré

---

## 📊 7. Tests de Données

### 7.1 Persistence MongoDB
- [ ] Données créées via API persistent après redémarrage
- [ ] Requêtes MongoDB log visible (si DEBUG)

### 7.2 Intégrité Données
- [ ] Pas de doublons non intentionnels
- [ ] Dates/timestamps correctes
- [ ] Relations entre collections OK

---

## 🔴 8. Tests d'Erreurs

### 8.1 Erreurs Frontend
- [ ] Page 404 affichée pour route inexistante
- [ ] Messages d'erreur clairs pour l'utilisateur
- [ ] Fallback UI fonctionnelle

### 8.2 Erreurs Backend
```bash
GET http://localhost:8081/api/invalid-endpoint
Authorization: Bearer {token}
```
- [ ] Status 404, message explicite
- [ ] Logs erreur visibles en DEBUG

### 8.3 Erreurs Réseau
- [ ] Perte connexion → message utilisateur
- [ ] Retry automatique (si implémenté)
- [ ] Timeout géré proprement

---

## 🔒 9. Tests Sécurité

### 9.1 HTTPS (Production)
- [ ] Dev: HTTP OK
- [ ] Production: HTTPS obligatoire
- [ ] Certificat SSL valide

### 9.2 Secrets en .env
- [ ] `.env` JAMAIS commité (vérifier .gitignore)
- [ ] JWT_SECRET ≥ 32 caractères
- [ ] API Keys masquées

### 9.3 Contrôle d'Accès (RBAC)
- [ ] Admin peut accéder routes admin
- [ ] User ne peut pas accéder routes admin
- [ ] User ne peut accéder que ses données

---

## 📈 10. Tests de Performance

### 10.1 Temps de Réponse
- [ ] Login < 1s
- [ ] GET list < 500ms
- [ ] POST creation < 500ms

### 10.2 Charge
- [ ] 10 requêtes simultanées → OK
- [ ] Pas de memory leak observé

---

## 📝 Template de Rapport

```
Date: [DATE]
Tester: [NOM]
Version App: [VERSION]

Nombre de tests: [X]
✅ Passés: [X]
❌ Échoués: [X]
⚠️ Avertissements: [X]

Bugs trouvés:
1. [Description du bug]
   - Pas à reproduire: [Étapes]
   - Sévérité: Critique/Majeur/Mineur
   - Capture d'écran: [Joindre si pertinent]

Commentaires:
[Observations supplémentaires]
```

---

**Conseil:** Exécuter ce plan après chaque merge/release pour garantir la stabilité! 🎯
