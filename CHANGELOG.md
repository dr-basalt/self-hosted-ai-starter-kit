# Changelog - Self-Hosted AI Starter Kit

## [2024-01-XX] - Ajout du Launcher et Correction des Dépendances

### ✨ Nouvelles fonctionnalités

#### 🚀 Launcher Automatique
- **`launcher.ps1`** : Script PowerShell pour Windows
- **`launcher.sh`** : Script Bash pour Linux/macOS
- **`LAUNCHER_README.md`** : Documentation complète du launcher

#### 🔧 Fonctionnalités du Launcher
- Installation automatique de Docker et Docker Compose
- Installation automatique de Python et pip
- Création automatique du fichier `.env`
- Détection automatique du type de GPU
- Support des profils CPU, GPU NVIDIA et GPU AMD
- Messages colorés et informatifs
- Gestion des erreurs

### 🐛 Corrections

#### 📦 Dépendances Python
- **Problème résolu** : Conflit entre `tokenizers==0.15.0` et `faster-whisper==0.9.0`
- **Solution** : Modification de `requirements.txt` pour utiliser `tokenizers>=0.13,<0.15`
- **Impact** : Résolution de l'erreur `ResolutionImpossible` lors du build Docker

### 📁 Nouveaux fichiers

- `launcher.ps1` - Launcher PowerShell pour Windows
- `launcher.sh` - Launcher Bash pour Linux/macOS
- `env.example` - Fichier d'exemple pour les variables d'environnement
- `LAUNCHER_README.md` - Documentation du launcher
- `simple-test.ps1` - Script de test simple
- `CHANGELOG.md` - Ce fichier

### 🔄 Modifications

- `requirements.txt` - Correction du conflit de dépendances tokenizers
- `docker-compose.yml` - Aucune modification (déjà fonctionnel)

### 🎯 Utilisation

#### Windows (PowerShell)
```powershell
# Afficher l'aide
.\launcher.ps1 help

# Lancer avec CPU
.\launcher.ps1 cpu

# Lancer avec GPU NVIDIA
.\launcher.ps1 gpu
```

#### Linux/macOS (Bash)
```bash
# Rendre exécutable
chmod +x launcher.sh

# Lancer avec CPU
./launcher.sh cpu

# Lancer avec GPU NVIDIA
./launcher.sh gpu
```

### 🧪 Test

Le launcher a été testé avec succès sur Windows PowerShell et fonctionne correctement pour :
- ✅ Affichage de l'aide
- ✅ Vérification des dépendances
- ✅ Création du fichier .env
- ✅ Lancement des services Docker

### 📋 Prochaines étapes

1. Tester le launcher sur Linux/macOS
2. Ajouter des tests automatisés
3. Améliorer la gestion des erreurs
4. Ajouter des options de configuration avancées
