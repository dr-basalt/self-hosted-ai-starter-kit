# OpenWebUI - Assistant IA Personnel

## Vue d'ensemble

Cette configuration ajoute OpenWebUI à votre kit de démarrage AI self-hosted avec les fonctionnalités suivantes :

- **Interface ChatGPT-like** accessible via navigateur
- **Modèles LLM** : tinyllama, phi3 (par défaut), qwen2.5, llama3.2, gemma2
- **STT/TTS** : Faster Whisper + Coqui TTS pour reconnaissance et synthèse vocale
- **Mémoire réflexive** : Sauvegarde automatique des conversations dans Qdrant
- **PWA** : Application mobile-like installable sur smartphone
- **API** : Endpoints pour intégration avec applications externes
- **Webhooks n8n** : Intégration avec votre workflow existant

## Installation

### 🏠 Développement local

#### 1. Prérequis

- Docker et Docker Compose installés
- Serveur Ollama accessible sur `http://taz.infra.ori3com.cloud:11434`
- Modèles LLM disponibles sur votre serveur Ollama

#### 2. Démarrage local

```bash
# Pour CPU uniquement
docker compose --profile cpu up -d

# Pour GPU NVIDIA
docker compose --profile gpu-nvidia up -d

# Pour GPU AMD
docker compose --profile gpu-amd up -d
```

### 🌐 Déploiement production avec Tailscale

#### 1. Prérequis production

- Serveur Linux avec Docker
- Tailscale installé et configuré
- Firewall configuré (ufw recommandé)

#### 2. Déploiement automatique

```bash
# Script de déploiement complet
chmod +x deploy-production.sh
./deploy-production.sh
```

#### 3. Configuration manuelle

```bash
# 1. Installer Tailscale
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
sudo apt-get update && sudo apt-get install tailscale

# 2. Configurer Tailscale
sudo tailscale up --advertise-tags=tag:openwebui-server

# 3. Configurer le firewall
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow in on tailscale0
sudo ufw allow from 100.64.0.0/10 to any port 3000,5001,5678,6333
sudo ufw --force enable

# 4. Démarrer les services
docker compose -f docker-compose.tailscale.yml --profile cpu up -d
```

### 3. Téléchargement des modèles

Les modèles suivants seront automatiquement téléchargés :

- `tinyllama:1.1b-chat` - Modèle léger pour conversations rapides
- `phi3:3.8b` - **Modèle par défaut** - équilibré performance/rapidité
- `qwen2.5:3b-instruct` - Modèle instruct optimisé pour les tâches
- `llama3.2:latest` - Dernière version de Llama 3.2
- `gemma2:2b` - Modèle Gemma 2 léger

## Accès

### 🏠 Développement local
- **OpenWebUI** : http://localhost:3000
- **n8n** : http://localhost:5678
- **Qdrant** : http://localhost:6333

### 🌐 Production (via Tailscale)
Après déploiement, utilisez l'IP Tailscale de votre serveur :
- **OpenWebUI** : http://[TAILSCALE_IP]:3000
- **n8n** : http://[TAILSCALE_IP]:5678
- **Qdrant** : http://[TAILSCALE_IP]:6333

L'IP Tailscale est affichée après le déploiement ou obtenue avec :
```bash
tailscale ip -4
```

### API Endpoints

#### OpenWebUI API
- `POST /api/v1/chat` - Chat avec le modèle LLM
- `GET /api/v1/models` - Liste des modèles disponibles

#### Mémoire API (port 5001)
- `POST /memory/save` - Sauvegarder une conversation
- `POST /memory/search` - Rechercher des conversations similaires
- `POST /memory/context` - Obtenir le contexte réflexif

#### Webhook n8n
- `POST /webhook/openwebui-chat` - Intégration via n8n

## Configuration

### Variables d'environnement

Ajoutez ces variables à votre fichier `.env` :

```env
# OpenWebUI
OLLAMA_HOST=http://taz.infra.ori3com.cloud:11434
QDRANT_HOST=qdrant
QDRANT_PORT=6333

# Modèle par défaut
DEFAULT_MODEL=phi3:3.8b
```

### Configuration STT/TTS

Le système utilise :
- **STT** : Faster Whisper (modèle `base`, optimisé CPU)
- **TTS** : Coqui TTS (modèle français `tts_models/fr/css10/vits`)

## Utilisation

### Interface Web

1. Ouvrez http://localhost:3000
2. Sélectionnez votre modèle préféré (phi3 par défaut)
3. Commencez à discuter - toutes les conversations sont sauvegardées
4. Utilisez les boutons microphone pour STT/TTS

### API Mobile

Pour votre application mobile existante :

```bash
curl -X POST http://localhost:5678/webhook/openwebui-chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Bonjour, comment allez-vous ?",
    "session_id": "mobile_session_123",
    "model": "phi3:3.8b"
  }'
```

### Intégration n8n

Le workflow `openwebui-integration.json` est automatiquement importé et permet :
- Réception de messages via webhook
- Appel d'OpenWebUI avec le modèle spécifié
- Sauvegarde automatique dans la mémoire Qdrant
- Retour de la réponse avec métadonnées

## PWA (Progressive Web App)

### Installation sur mobile

1. Ouvrez http://localhost:3000 sur votre smartphone
2. Ajoutez à l'écran d'accueil
3. L'icône apparaîtra comme une application native
4. Expérience mobile optimisée

### Personnalisation

Pour personnaliser l'apparence :

1. Modifiez `openwebui-pwa.json` pour changer :
   - Nom de l'application
   - Couleurs du thème
   - Icônes

2. Ajoutez vos icônes dans `/app/open-webui/static/icons/`

## Mémoire et RAG

### Fonctionnalités

- **Sauvegarde automatique** : Chaque conversation est stockée dans Qdrant
- **Recherche sémantique** : Trouve des conversations similaires
- **Contexte réflexif** : Utilise l'historique pour améliorer les réponses
- **Embeddings locaux** : Utilise `all-MiniLM-L6-v2` pour les vecteurs

### Structure des données

```json
{
  "user_message": "Question de l'utilisateur",
  "ai_response": "Réponse de l'IA",
  "model_used": "phi3:3.8b",
  "session_id": "session_123",
  "timestamp": "2024-01-01T12:00:00Z",
  "combined_text": "User: Question\nAI: Réponse"
}
```

## Monitoring

### Logs

```bash
# Logs OpenWebUI
docker logs openwebui

# Logs mémoire API
docker logs openwebui -f | grep "memory"

# Logs Qdrant
docker logs qdrant
```

### Métriques

- **Utilisation mémoire** : Surveillez via l'API `/memory/stats`
- **Performance** : Logs de temps de réponse dans OpenWebUI
- **Stockage** : Taille de la collection Qdrant

## Dépannage

### Problèmes courants

1. **Modèles non trouvés** :
   ```bash
   docker exec -it ollama-cpu ollama list
   ```

2. **API mémoire inaccessible** :
   ```bash
   curl http://localhost:5001/memory/search -X POST -H "Content-Type: application/json" -d '{"query":"test"}'
   ```

3. **STT/TTS ne fonctionne pas** :
   - Vérifiez que ffmpeg est installé
   - Testez avec un fichier audio simple

### Logs détaillés

```bash
# Activer les logs détaillés
docker compose logs -f openwebui
```

## Développement

### Ajouter un nouveau modèle

1. Ajoutez le modèle dans `openwebui-config.yml`
2. Ajoutez le pull dans le docker-compose.yml
3. Redémarrez les services

### Personnaliser l'interface

1. Clonez le repo OpenWebUI
2. Modifiez les composants React
3. Rebuild l'image Docker

## Support

Pour toute question ou problème :
- Consultez les logs Docker
- Vérifiez la connectivité réseau
- Testez les endpoints API individuellement
