# Demarrage de l'application AgriSmart Mobile

Ce guide explique comment installer le necessaire et lancer l'application Flutter en local sur Windows.

## 1) Prerequis

- Git installe
- Google Chrome installe (pour lancement web rapide)
- Flutter SDK installe

Option recommandee dans ce projet:

```powershell
# Exemple de chemin SDK
C:\Users\hdjeb\flutter\bin\flutter.bat --version
```

Si `flutter` n'est pas reconnu, utilisez le chemin complet vers `flutter.bat` dans les commandes.

## 2) Ouvrir le projet

```powershell
cd C:\Users\hdjeb\OneDrive\Bureau\Esprit\pi_sleam\git\Agrismart_mobile
```

## 3) Installer les dependances

```powershell
C:\Users\hdjeb\flutter\bin\flutter.bat pub get
```

## 4) Lancer l'application

### Option A: Web (rapide)

```powershell
C:\Users\hdjeb\flutter\bin\flutter.bat run -d chrome
```

### Option B: Windows desktop

```powershell
C:\Users\hdjeb\flutter\bin\flutter.bat run -d windows
```

## 5) Commandes utiles en mode run

- `r` : hot reload
- `R` : hot restart
- `q` : quitter

## 6) Verification environnement

```powershell
C:\Users\hdjeb\flutter\bin\flutter.bat doctor -v
```

## 7) Probleme frequent et solution

### Erreur symlink/plugin build sur Windows

Si vous voyez un message lie a `symlink support`, activez le Developer Mode Windows:

```powershell
start ms-settings:developers
```

Puis relancez:

```powershell
C:\Users\hdjeb\flutter\bin\flutter.bat pub get
```

### Port web deja occupe

Lancez sans fixer de port (Flutter en choisira un libre):

```powershell
C:\Users\hdjeb\flutter\bin\flutter.bat run -d chrome
```

## 8) Backend local (optionnel)

Si certaines fonctionnalites (auth, API) ne repondent pas, demarrez aussi le backend `spring_boot-main` depuis le workspace principal AgriSmart.
