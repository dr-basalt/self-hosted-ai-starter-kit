#!/bin/bash

# Script de déploiement production avec Tailscale
echo "🚀 Déploiement production OpenWebUI avec Tailscale..."

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Vérifier les prérequis
echo -e "${BLUE}🔍 Vérification des prérequis...${NC}"

# Vérifier Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker n'est pas installé${NC}"
    exit 1
fi

# Vérifier Docker Compose
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose n'est pas installé${NC}"
    exit 1
fi

# Vérifier Tailscale
if ! command -v tailscale &> /dev/null; then
    echo -e "${YELLOW}⚠️  Tailscale n'est pas installé. Installation...${NC}"
    ./setup-tailscale.sh
fi

# Obtenir l'IP Tailscale
TAILSCALE_IP=$(tailscale ip -4)
if [ -z "$TAILSCALE_IP" ]; then
    echo -e "${RED}❌ Impossible d'obtenir l'IP Tailscale${NC}"
    exit 1
fi

echo -e "${GREEN}✅ IP Tailscale: $TAILSCALE_IP${NC}"

# Créer le fichier .env s'il n'existe pas
if [ ! -f .env ]; then
    echo -e "${BLUE}📝 Création du fichier .env...${NC}"
    cat > .env << EOF
# Configuration de base
POSTGRES_USER=n8n
POSTGRES_PASSWORD=n8n
POSTGRES_DB=n8n
N8N_ENCRYPTION_KEY=$(openssl rand -hex 32)
N8N_USER_MANAGEMENT_JWT_SECRET=$(openssl rand -hex 32)

# Configuration Ollama
OLLAMA_HOST=http://taz.infra.ori3com.cloud:11434

# Configuration OpenWebUI
OPENWEBUI_PORT=3000
MEMORY_API_PORT=5001
DEFAULT_MODEL=phi3:3.8b

# Configuration Qdrant
QDRANT_HOST=qdrant
QDRANT_PORT=6333

# Configuration Tailscale
TAILSCALE_IP=$TAILSCALE_IP

# Configuration STT/TTS
STT_MODEL=base
TTS_MODEL=tts_models/fr/css10/vits
STT_LANGUAGE=fr

# Configuration PWA
PWA_NAME="OpenWebUI - Assistant IA Personnel"
PWA_SHORT_NAME="OpenWebUI"
PWA_THEME_COLOR="#3b82f6"
EOF
    echo -e "${GREEN}✅ Fichier .env créé${NC}"
fi

# Créer le réseau Tailscale Docker
echo -e "${BLUE}🌐 Création du réseau Tailscale Docker...${NC}"
docker network create tailscale 2>/dev/null || echo -e "${YELLOW}⚠️  Réseau Tailscale existe déjà${NC}"

# Démarrer les services
echo -e "${BLUE}🚀 Démarrage des services...${NC}"

# Détecter le type de GPU
if command -v nvidia-smi &> /dev/null; then
    echo -e "${GREEN}🎮 GPU NVIDIA détecté${NC}"
    PROFILE="gpu-nvidia"
elif command -v rocm-smi &> /dev/null; then
    echo -e "${GREEN}🎮 GPU AMD détecté${NC}"
    PROFILE="gpu-amd"
else
    echo -e "${YELLOW}💻 Mode CPU${NC}"
    PROFILE="cpu"
fi

# Démarrer avec le profil approprié
echo -e "${BLUE}📦 Démarrage avec le profil: $PROFILE${NC}"
docker compose -f docker-compose.tailscale.yml --profile $PROFILE up -d

# Attendre que les services démarrent
echo -e "${BLUE}⏳ Attente du démarrage des services...${NC}"
sleep 30

# Vérifier l'état des services
echo -e "${BLUE}🔍 Vérification de l'état des services...${NC}"
docker compose -f docker-compose.tailscale.yml ps

# Créer le fichier d'URLs
cat > openwebui-production-urls.txt << EOF
# 🌐 URLs d'accès production sécurisées via Tailscale
# IP Tailscale: $TAILSCALE_IP
# Déployé le: $(date)

🚀 OpenWebUI (Interface principale)
   http://$TAILSCALE_IP:3000

🔧 n8n (Workflows et webhooks)
   http://$TAILSCALE_IP:5678

🧠 API Mémoire (Endpoints mémoire)
   http://$TAILSCALE_IP:5001

🗄️  Qdrant (Base de données vectorielle)
   http://$TAILSCALE_IP:6333

📱 Webhook pour app mobile
   http://$TAILSCALE_IP:5678/webhook/openwebui-chat

🔒 Sécurité
   - Accès uniquement via réseau Tailscale
   - Firewall configuré pour bloquer l'accès externe
   - Ports exposés uniquement sur l'interface Tailscale
   - Chiffrement automatique des communications

📋 Commandes utiles
   - Voir les logs: docker compose -f docker-compose.tailscale.yml logs -f
   - Redémarrer: docker compose -f docker-compose.tailscale.yml restart
   - Arrêter: docker compose -f docker-compose.tailscale.yml down
   - Mettre à jour: docker compose -f docker-compose.tailscale.yml pull && docker compose -f docker-compose.tailscale.yml up -d
EOF

echo -e "${GREEN}✅ Déploiement terminé !${NC}"
echo -e "${BLUE}📋 URLs d'accès sauvegardées dans: openwebui-production-urls.txt${NC}"

# Afficher les URLs
echo -e "\n${BLUE}🌐 URLs d'accès:${NC}"
echo -e "${GREEN}OpenWebUI:${NC} http://$TAILSCALE_IP:3000"
echo -e "${GREEN}n8n:${NC} http://$TAILSCALE_IP:5678"
echo -e "${GREEN}API Mémoire:${NC} http://$TAILSCALE_IP:5001"
echo -e "${GREEN}Qdrant:${NC} http://$TAILSCALE_IP:6333"

echo -e "\n${YELLOW}🔑 Pour accéder depuis d'autres appareils:${NC}"
echo -e "1. Installez Tailscale sur l'appareil"
echo -e "2. Connectez-vous au même réseau Tailscale"
echo -e "3. Utilisez les URLs ci-dessus"

echo -e "\n${GREEN}🎉 Votre assistant IA personnel est prêt !${NC}"
