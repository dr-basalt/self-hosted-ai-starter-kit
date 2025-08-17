# Launcher Self-Hosted AI Starter Kit

Ce launcher automatise l'installation et le lancement de votre environnement Self-Hosted AI Starter Kit.

## 🚀 Utilisation

### Sur Windows (PowerShell)

```powershell
# Afficher l'aide
.\launcher.ps1 help

# Lancer avec CPU
.\launcher.ps1 cpu

# Lancer avec GPU NVIDIA
.\launcher.ps1 gpu

# Lancer avec GPU AMD (utilise CPU sur Windows)
.\launcher.ps1 gpu-amd
```

### Sur Linux/macOS (Bash)

```bash
# Rendre le script exécutable (première fois seulement)
chmod +x launcher.sh

# Afficher l'aide
./launcher.sh help

# Lancer avec CPU
./launcher.sh cpu

# Lancer avec GPU NVIDIA
./launcher.sh gpu

# Lancer avec GPU AMD
./launcher.sh gpu-amd
```

## 🔧 Fonctionnalités

Le launcher effectue automatiquement les tâches suivantes :

1. **Vérification des dépendances** :
   - Docker et Docker Compose
   - Python 3 et pip

2. **Installation automatique** (si nécessaire) :
   - Docker Desktop (Windows)
   - Docker Engine (Linux)
   - Docker Compose v2
   - Python 3 et pip

3. **Configuration** :
   - Création du fichier `.env` à partir de `.env.example`
   - Configuration des variables d'environnement

4. **Lancement des services** :
   - Détection automatique du type de GPU
   - Lancement avec le profil approprié (CPU/GPU NVIDIA/GPU AMD)

## 📋 Prérequis

### Windows
- Windows 10/11
- PowerShell 5.1 ou plus récent
- Connexion Internet pour télécharger Docker Desktop

### Linux
- Distribution basée sur Debian/Ubuntu
- Accès sudo
- Connexion Internet

### macOS
- macOS 10.15 ou plus récent
- Connexion Internet

## 🎯 Profils disponibles

### CPU
- Utilise uniquement le processeur
- Compatible avec tous les systèmes
- Performance limitée pour l'IA

### GPU NVIDIA
- Utilise les GPU NVIDIA
- Nécessite les drivers NVIDIA
- Performance optimale pour l'IA

### GPU AMD
- Utilise les GPU AMD (Linux uniquement)
- Nécessite les drivers AMD ROCm
- Performance optimale pour l'IA

## 🌐 Services disponibles

Une fois lancé, les services suivants seront disponibles :

- **OpenWebUI** : http://localhost:3000
- **N8N** : http://localhost:5678
- **Qdrant** : http://localhost:6333
- **Ollama** : http://localhost:11434

## 🛠️ Commandes utiles

```bash
# Voir les logs en temps réel
docker-compose logs -f

# Voir les logs d'un service spécifique
docker-compose logs -f openwebui

# Arrêter tous les services
docker-compose down

# Redémarrer les services
docker-compose restart

# Reconstruire les images
docker-compose build --no-cache
```

## 🔍 Dépannage

### Erreur de dépendances Python
Si vous rencontrez des erreurs de dépendances Python (comme le conflit tokenizers), le launcher a corrigé le fichier `requirements.txt` pour résoudre les conflits.

### Docker non démarré
Assurez-vous que Docker Desktop (Windows) ou Docker Engine (Linux) est en cours d'exécution.

### Ports déjà utilisés
Si les ports sont déjà utilisés, arrêtez les services qui les utilisent ou modifiez les ports dans `docker-compose.yml`.

### GPU non détecté
- **NVIDIA** : Installez les drivers NVIDIA et NVIDIA Container Toolkit
- **AMD** : Installez les drivers AMD ROCm (Linux uniquement)

## 📝 Notes

- Le launcher crée automatiquement un fichier `.env` basique si `.env.example` n'existe pas
- Les clés de chiffrement N8N doivent être modifiées dans le fichier `.env` pour la production
- Le support GPU AMD sur Windows utilise le profil CPU par défaut
- Tous les modèles Ollama sont téléchargés automatiquement au premier lancement

## 🤝 Support

Si vous rencontrez des problèmes :

1. Vérifiez que Docker est en cours d'exécution
2. Consultez les logs avec `docker-compose logs`
3. Vérifiez que tous les prérequis sont installés
4. Consultez la documentation du projet principal
