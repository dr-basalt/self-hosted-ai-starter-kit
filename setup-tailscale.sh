#!/bin/bash

# Script de configuration Tailscale pour OpenWebUI
echo "🔒 Configuration Tailscale pour sécuriser l'accès externe..."

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Vérifier si Tailscale est installé
if ! command -v tailscale &> /dev/null; then
    echo -e "${RED}❌ Tailscale n'est pas installé${NC}"
    echo -e "${YELLOW}📥 Installation de Tailscale...${NC}"
    
    # Installation selon le système
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
        curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
        sudo apt-get update
        sudo apt-get install tailscale
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        brew install tailscale
    else
        echo -e "${RED}❌ Système non supporté. Installez Tailscale manuellement.${NC}"
        exit 1
    fi
fi

# Démarrer Tailscale
echo -e "${BLUE}🚀 Démarrage de Tailscale...${NC}"
sudo tailscale up --advertise-tags=tag:openwebui-server

# Obtenir l'IP Tailscale
TAILSCALE_IP=$(tailscale ip -4)
echo -e "${GREEN}✅ IP Tailscale: $TAILSCALE_IP${NC}"

# Configuration du firewall avec ufw (si disponible)
if command -v ufw &> /dev/null; then
    echo -e "${BLUE}🔥 Configuration du firewall...${NC}"
    
    # Réinitialiser les règles
    sudo ufw --force reset
    
    # Règles par défaut
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    
    # Autoriser Tailscale
    sudo ufw allow in on tailscale0
    sudo ufw allow out on tailscale0
    
    # Autoriser les ports locaux uniquement depuis Tailscale
    sudo ufw allow from 100.64.0.0/10 to any port 3000  # OpenWebUI
    sudo ufw allow from 100.64.0.0/10 to any port 5001  # API Mémoire
    sudo ufw allow from 100.64.0.0/10 to any port 5678  # n8n
    sudo ufw allow from 100.64.0.0/10 to any port 6333  # Qdrant
    
    # Autoriser SSH depuis Tailscale
    sudo ufw allow from 100.64.0.0/10 to any port 22
    
    # Activer le firewall
    sudo ufw --force enable
    
    echo -e "${GREEN}✅ Firewall configuré${NC}"
else
    echo -e "${YELLOW}⚠️  ufw non disponible. Configurez votre firewall manuellement.${NC}"
fi

# Créer un fichier de configuration pour les URLs
echo -e "${BLUE}📝 Création du fichier de configuration...${NC}"
cat > openwebui-urls.txt << EOF
# URLs d'accès sécurisées via Tailscale
# IP Tailscale: $TAILSCALE_IP

🌐 OpenWebUI (Interface principale)
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
EOF

echo -e "${GREEN}✅ Configuration terminée !${NC}"
echo -e "${BLUE}📋 URLs d'accès sauvegardées dans: openwebui-urls.txt${NC}"
echo -e "${YELLOW}🔑 Pour autoriser d'autres appareils, utilisez: tailscale up --advertise-tags=tag:openwebui-client${NC}"

# Afficher les URLs
echo -e "\n${BLUE}🌐 URLs d'accès:${NC}"
echo -e "${GREEN}OpenWebUI:${NC} http://$TAILSCALE_IP:3000"
echo -e "${GREEN}n8n:${NC} http://$TAILSCALE_IP:5678"
echo -e "${GREEN}API Mémoire:${NC} http://$TAILSCALE_IP:5001"
echo -e "${GREEN}Qdrant:${NC} http://$TAILSCALE_IP:6333"
