# 🚀 Quick Start - Test Manuel AgriSmart

## 1. Préparation (Une seule fois)

### Étape 1: Configuration .env
```powershell
cd SprintWeb
Copy-Item .env.example .env
```

**Vérifiez les variables critiques dans `.env`:**
- `JWT_SECRET` = min 32 caractères ✅
- `CHATBOT_ADMIN_TOKEN` = valeur unique ✅

### Étape 2: Lancer les services
```powershell
# Terminal 1 - Racine du projet
powershell -ExecutionPolicy Bypass -File .\start-all.ps1
```

Attendez que tous les services soient UP (2-3 minutes):
- ✅ MongoDB connectée
- ✅ Spring Boot démarré
- ✅ Flask prêt
- ✅ Angular serveur de dev

---

## 2. Vérification Rapide

### Vérifier que tout fonctionne:
```powershell
# Terminal 2 - Dans le dossier testing
.\verify-all.ps1
```

Vous devriez voir:
```
✅ MongoDB is accessible
✅ Backend Spring Boot is running
✅ Chatbot Flask is running
✅ API Gateway is running
✅ Frontend is accessible
✅ Authentication successful
...
✨ ALL TESTS PASSED!
```

---

## 3. Accéder à l'Application

| Service | URL | Pour |
|---------|-----|------|
| **Frontend** | http://localhost:4200 | Interface web |
| **API** | http://localhost:8081/api | Requêtes API |
| **Chatbot** | http://localhost:5005 | Service IA |
| **Logs Backend** | http://localhost:8080/actuator/loggers | Déboguer |

### Se connecter:
```
Email: admin@agrismart.gn
Password: admin123
```

---

## 4. Tester via API (Postman/Insomnia)

### Importer la collection:
1. Ouvrir **Postman** ou **Insomnia**
2. Importer: `testing/api-collection.postman.json`
3. Définir variables:
   - `gateway_url`: `http://localhost:8081`
   - `admin_token`: `admin-token-test-123456`

### Tester l'authentification:
```
1. Exécuter: "Authentication > Login Admin"
2. Voir le token reçu
3. Copier le token dans variable {{token}}
4. Exécuter: "Users > Get My Profile"
```

---

## 5. Suivre le Plan de Test Complet

Voir [MANUAL_TEST_PLAN.md](MANUAL_TEST_PLAN.md) pour:
- ✅ Tests d'authentification
- ✅ Tests frontend
- ✅ Tests API backend
- ✅ Tests chatbot
- ✅ Tests sécurité
- ✅ Gestion d'erreurs

---

## 6. Dépannage Courant

### ❌ "Cannot connect to MongoDB"
```powershell
# Vérifier que MongoDB est actif
Get-Service MongoDB
# Si pas actif:
net start MongoDB
```

### ❌ "Port 8080 already in use"
```powershell
# Trouver process utilisant le port
netstat -ano | findstr :8080
# Ou redémarrer tout:
.\start-all.ps1
```

### ❌ "Cannot GET /api/users/profile"
- Vérifier JWT token valide
- Vérifier Authorization header: `Bearer {token}`
- Logs: http://localhost:8080/actuator/loggers

### ❌ "CORS error in browser"
- Vérifier `CORS_ALLOWED_ORIGINS` dans .env
- Doit inclure: `http://localhost:4200`

---

## 7. Scénario Test Basique (5 minutes)

```
1. Ouvrir http://localhost:4200
   → Voir page login

2. Se connecter
   Email: admin@agrismart.gn
   Password: admin123
   → Dashboard affichée

3. Tester une page (ex: Tâches)
   → Données affichées

4. Tester API (terminal):
   curl -H "Authorization: Bearer {token}" \
        http://localhost:8081/api/users/profile
   → Données JSON retournées

5. Tester Chatbot (Postman):
   POST http://localhost:8081/chatbot/api/message
   Body: {"message": "Bonjour"}
   → Réponse reçue

✅ Tous les 5 points = Test OK!
```

---

## 8. Outils Recommandés

```powershell
# Installer Postman (si pas déjà)
choco install postman

# Installer MongoDB Compass (GUI)
choco install mongodb-compass

# Installer curl (pour tests CLI)
choco install curl
```

---

## 9. Faire un Rapport

Voir [test-data.md](test-data.md) > "Template de Rapport"

Exemple:
```
Date: 22/03/2026
Tester: Jean Dupont
✅ Tests Passés: 47/50
❌ Tests Échoués: 3

Bugs:
- Chatbot timeout (LLM API down)
- Typo dans label bouton
- Responsive design bug sur mobile
```

---

## 📞 Support

| Problème | Essayer |
|----------|---------|
| Service down | `./verify-all.ps1` |
| Logs erreur | `http://localhost:8080/actuator/loggers` |
| API répond 500 | Vérifier `.env` variables |
| CORS error | Spring Boot application.yml |
| Chatbot pas de réponse | Vérifier JWT token valide |

---

**Dans le doute, redémarrer tout:**
```powershell
# Tuer les processus
Stop-Process -Name "java" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "node" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "python" -Force -ErrorAction SilentlyContinue

# Relancer
.\start-all.ps1
```

Bon test! 🎯
