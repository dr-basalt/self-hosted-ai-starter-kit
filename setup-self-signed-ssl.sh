#!/bin/bash

# Script de configuration SSL auto-signé pour OpenWebUI
# Usage: ./setup-self-signed-ssl.sh

set -e

DOMAIN="taz.infra.ori3com.cloud"

echo "🔐 Configuration SSL auto-signé pour OpenWebUI"
echo "=============================================="
echo "Domaine: $DOMAIN"
echo ""

# Créer le répertoire pour les certificats
echo "📁 Création du répertoire des certificats..."
mkdir -p /app/certs

# Arrêter temporairement OpenWebUI
echo "⏸️  Arrêt temporaire d'OpenWebUI..."
cd /root/self-hosted-ai-starter-kit
docker compose stop openwebui

# Générer un certificat SSL auto-signé
echo "🔐 Génération du certificat SSL auto-signé..."
openssl req -x509 -newkey rsa:4096 -keyout /app/certs/key.pem -out /app/certs/cert.pem -days 365 -nodes \
    -subj "/C=FR/ST=France/L=Paris/O=OpenWebUI/OU=IT/CN=$DOMAIN" \
    -addext "subjectAltName=DNS:$DOMAIN,DNS:localhost,IP:127.0.0.1,IP:135.181.25.208"

# Définir les permissions
chmod 644 /app/certs/cert.pem
chmod 600 /app/certs/key.pem

# Redémarrer OpenWebUI avec HTTPS
echo "🚀 Redémarrage d'OpenWebUI avec HTTPS..."
docker compose up -d openwebui

echo ""
echo "✅ Configuration SSL auto-signé terminée!"
echo "🌐 Accédez à OpenWebUI: https://$DOMAIN:3000"
echo "⚠️  Note: Le navigateur affichera un avertissement de sécurité (normal pour un certificat auto-signé)"
echo ""
echo "📋 Informations importantes:"
echo "   - Certificat valide jusqu'au: $(openssl x509 -in /app/certs/cert.pem -text -noout | grep 'Not After')"
echo "   - Pour un certificat Let's Encrypt, configurez le DNS pour pointer vers 135.181.25.208"
echo ""
echo "🔧 Pour configurer Let's Encrypt plus tard:"
echo "   1. Configurez le DNS: taz.infra.ori3com.cloud -> 135.181.25.208"
echo "   2. Exécutez: ./setup-ssl.sh"
