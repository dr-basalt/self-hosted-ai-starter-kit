#!/bin/bash

# Script de configuration SSL avec Let's Encrypt pour OpenWebUI
# Usage: ./setup-ssl.sh

set -e

DOMAIN="taz.infra.ori3com.cloud"
EMAIL="admin@taz.infra.ori3com.cloud"

echo "🔐 Configuration SSL pour OpenWebUI"
echo "==================================="
echo "Domaine: $DOMAIN"
echo "Email: $EMAIL"
echo ""

# Vérifier que certbot est installé
if ! command -v certbot &> /dev/null; then
    echo "📦 Installation de certbot..."
    apt-get update
    apt-get install -y certbot
fi

# Créer le répertoire pour les certificats
echo "📁 Création du répertoire des certificats..."
mkdir -p /app/certs

# Arrêter temporairement OpenWebUI pour libérer le port 80
echo "⏸️  Arrêt temporaire d'OpenWebUI..."
cd /root/self-hosted-ai-starter-kit
docker compose stop openwebui

# Obtenir le certificat Let's Encrypt
echo "🔐 Obtention du certificat Let's Encrypt..."
certbot certonly \
    --standalone \
    --email "$EMAIL" \
    --agree-tos \
    --no-eff-email \
    --domains "$DOMAIN"

# Copier les certificats dans le répertoire d'OpenWebUI
echo "📋 Copie des certificats..."
cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem /app/certs/cert.pem
cp /etc/letsencrypt/live/$DOMAIN/privkey.pem /app/certs/key.pem

# Définir les permissions
chmod 644 /app/certs/cert.pem
chmod 600 /app/certs/key.pem

# Créer un script de renouvellement automatique
echo "🔄 Configuration du renouvellement automatique..."
cat > /etc/cron.d/letsencrypt-renew << EOF
# Renouvellement automatique des certificats Let's Encrypt
0 12 * * * root certbot renew --quiet --pre-hook "cd /root/self-hosted-ai-starter-kit && docker compose stop openwebui" --post-hook "cd /root/self-hosted-ai-starter-kit && docker compose start openwebui && cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem /app/certs/cert.pem && cp /etc/letsencrypt/live/$DOMAIN/privkey.pem /app/certs/key.pem && chmod 644 /app/certs/cert.pem && chmod 600 /app/certs/key.pem"
EOF

# Redémarrer OpenWebUI avec HTTPS
echo "🚀 Redémarrage d'OpenWebUI avec HTTPS..."
docker compose up -d openwebui

echo ""
echo "✅ Configuration SSL terminée!"
echo "🌐 Accédez à OpenWebUI: https://$DOMAIN:3000"
echo "🔄 Le certificat sera renouvelé automatiquement"
echo ""
echo "📋 Informations importantes:"
echo "   - Certificat valide jusqu'au: $(openssl x509 -in /app/certs/cert.pem -text -noout | grep 'Not After')"
echo "   - Renouvellement automatique: tous les jours à 12h00"
echo "   - Logs de renouvellement: /var/log/letsencrypt/"
