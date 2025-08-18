# Self-Hosted AI Starter Kit

🚀 **Kit de démarrage complet pour l'IA auto-hébergée** avec OpenWebUI, Ollama, Qdrant, N8N et PostgreSQL.

## ✨ Fonctionnalités

- **🤖 OpenWebUI Bundle** : Interface web moderne pour interagir avec les LLMs
- **🧠 Mémoire persistante** : Stockage vectoriel avec Qdrant et séparateur tenant `<email>:`
- **🎤 STT/TTS OpenAI** : Reconnaissance et synthèse vocale via API OpenAI
- **🔐 HTTPS Let's Encrypt** : Certificats SSL automatiques
- **📊 Persistance complète** : Toutes les données sauvegardées dans des volumes Docker
- **⚡ Modèles optimisés** : Configuration automatique des paramètres pour Llama2, Phi-3, Gemma2
- **🔧 N8N** : Automatisation des workflows
- **🗄️ PostgreSQL** : Base de données relationnelle

## 🚀 Installation rapide

### Prérequis
- Docker et Docker Compose v2
- Python 3.8+
- Domaine configuré (pour Let's Encrypt)

### 1. Cloner le repository
```bash
git clone https://github.com/dr-basalt/self-hosted-ai-starter-kit.git
cd self-hosted-ai-starter-kit
```

### 2. Configuration initiale
```bash
# Configuration complète avec CPU
./launcher.sh cpu --setup --configure --letsencrypt

# Ou étape par étape
./launcher.sh cpu --setup
./launcher.sh cpu --configure
./launcher.sh cpu --letsencrypt
```

### 3. Configuration des variables d'environnement
```bash
cp env.example .env
# Éditer .env avec vos clés API et domaines
```

## 📋 Configuration

### Variables d'environnement importantes

```bash
# OpenAI API (requis pour STT/TTS)
OPENAI_API_KEY=your-openai-api-key-here

# Let's Encrypt
LETSENCRYPT_EMAIL=admin@votre-domaine.com
LETSENCRYPT_DOMAIN=votre-domaine.com

# Sécurité
WEBUI_SECRET_KEY=your-secret-key-here
```

### Profils disponibles

- **CPU** : `./launcher.sh cpu` - Pour serveurs sans GPU
- **GPU NVIDIA** : `./launcher.sh gpu` - Pour serveurs avec GPU NVIDIA
- **GPU AMD** : `./launcher.sh gpu-amd` - Pour serveurs avec GPU AMD

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   OpenWebUI     │    │     Ollama      │    │     Qdrant      │
│   (Bundle)      │◄──►│   (LLM API)     │    │  (Vector DB)    │
│   Port: 3000    │    │   Port: 11434   │    │   Port: 6333    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│      N8N        │    │   PostgreSQL    │    │   Let's Encrypt │
│  (Workflows)    │    │   (Database)    │    │   (SSL Certs)   │
│   Port: 5678    │    │   Port: 5432    │    │   Auto-renewal  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🧠 Mémoire et Embeddings

### Configuration automatique
- **Modèle d'embedding** : `all-MiniLM-L6-v2` (optimisé pour la performance)
- **Séparateur tenant** : `:` (format: `<email>:contenu`)
- **Collection Qdrant** : `openwebui_memory`
- **Seuil de similarité** : 0.7
- **Résultats max** : 10

### Exemple d'utilisation
```python
# Les conversations sont automatiquement vectorisées
# avec le format: user@example.com:contenu du message
# Permettant l'isolation des données par utilisateur
```

## 🎤 Configuration STT/TTS

### OpenAI API (recommandé)
- **STT** : Whisper-1 pour la reconnaissance vocale
- **TTS** : TTS-1 avec voix "alloy"
- **Formats supportés** : WAV, MP3, M4A, WebM

### Configuration automatique
Le script `configure-models.py` configure automatiquement :
- Les paramètres optimisés pour chaque modèle
- Les templates de prompts
- Les séquences d'arrêt
- Les permissions utilisateur

## 🔐 Sécurité HTTPS

### Let's Encrypt automatique
- **Certificats SSL** : Génération automatique
- **Renouvellement** : Tous les jours à 12h00
- **Domaine** : Configurable via `LETSENCRYPT_DOMAIN`
- **Email** : Configurable via `LETSENCRYPT_EMAIL`

### Installation manuelle
```bash
./setup-letsencrypt.sh votre-domaine.com votre-email@domaine.com
```

## 📊 Persistance des données

### Volumes Docker
- `openwebui_data` : Données utilisateur et conversations
- `openwebui_uploads` : Fichiers uploadés
- `openwebui_logs` : Logs d'application
- `qdrant_data` : Base vectorielle
- `ollama_data` : Modèles LLM
- `postgres_data` : Base de données
- `n8n_data` : Workflows N8N
- `letsencrypt_certs` : Certificats SSL

### Sauvegarde
```bash
# Sauvegarder toutes les données
docker compose down
tar -czf backup-$(date +%Y%m%d).tar.gz \
  $(docker volume inspect -f '{{.Mountpoint}}' \
    openwebui_data openwebui_uploads qdrant_data \
    ollama_data postgres_data n8n_data)
```

## 🔧 Modèles LLM optimisés

### Configuration automatique
Le script configure automatiquement les paramètres optimisés :

| Modèle | Temperature | Top-P | Max Tokens | Context |
|--------|-------------|-------|------------|---------|
| Llama2 | 0.7 | 0.9 | 2048 | 4096 |
| Phi-3 | 0.8 | 0.95 | 4096 | 8192 |
| Gemma2 | 0.6 | 0.85 | 3072 | 6144 |

### Templates de prompts
- **Llama2** : `<s>[INST] {prompt} [/INST]`
- **Phi-3** : `<|user|>\n{prompt}<|end|>\n<|assistant|>`
- **Gemma2** : `<start_of_turn>user\n{prompt}<end_of_turn>\n<start_of_turn>model\n`

## 🚀 Commandes utiles

### Gestion des services
```bash
# Démarrer tous les services
./launcher.sh cpu

# Voir les logs
docker compose logs -f openwebui

# Redémarrer un service
docker compose restart openwebui

# Arrêter tous les services
docker compose down

# Nettoyer les volumes (⚠️ supprime toutes les données)
docker compose down -v
```

### Configuration
```bash
# Configuration complète
./launcher.sh cpu --setup --configure --letsencrypt

# Configuration manuelle des modèles
python3 configure-models.py

# Configuration Let's Encrypt manuelle
./setup-letsencrypt.sh domaine.com email@domaine.com
```

### Monitoring
```bash
# Statut des services
docker compose ps

# Utilisation des ressources
docker stats

# Logs en temps réel
docker compose logs -f
```

## 🔍 Dépannage

### Problèmes courants

#### OpenWebUI ne démarre pas
```bash
# Vérifier les logs
docker compose logs openwebui

# Vérifier la configuration
docker compose config

# Redémarrer le service
docker compose restart openwebui
```

#### Problèmes de mémoire Qdrant
```bash
# Vérifier la connexion
curl http://localhost:6333/health

# Redémarrer Qdrant
docker compose restart qdrant
```

#### Certificats Let's Encrypt
```bash
# Vérifier les certificats
openssl x509 -in /app/certs/cert.pem -text -noout

# Renouveler manuellement
certbot renew
```

### Logs et debugging
```bash
# Logs détaillés
docker compose logs -f --tail=100 openwebui

# Shell dans le conteneur
docker compose exec openwebui bash

# Vérifier les variables d'environnement
docker compose exec openwebui env | grep -E "(OLLAMA|QDRANT|MEMORY)"
```

## 📈 Performance

### Recommandations système
- **CPU** : 4+ cœurs pour les modèles de base
- **RAM** : 8GB minimum, 16GB recommandé
- **Stockage** : 50GB+ pour les modèles et données
- **GPU** : Optionnel mais recommandé pour les gros modèles

### Optimisations
- **Embeddings** : `all-MiniLM-L6-v2` (384 dimensions, rapide)
- **Qdrant** : Indexation automatique des vecteurs
- **Ollama** : Chargement à la demande des modèles
- **OpenWebUI** : Bundle pré-compilé (pas de build)

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 🙏 Remerciements

- [OpenWebUI](https://github.com/open-webui/open-webui) - Interface web moderne
- [Ollama](https://ollama.ai/) - Serveur LLM local
- [Qdrant](https://qdrant.tech/) - Base de données vectorielle
- [N8N](https://n8n.io/) - Automatisation des workflows

---

**🎯 Objectif** : Fournir une solution complète et prête à l'emploi pour l'IA auto-hébergée avec une configuration optimisée et une persistance des données.
