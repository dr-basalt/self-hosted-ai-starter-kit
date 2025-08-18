#!/bin/bash

# Script de configuration nginx avec SSL pour OpenWebUI
# Usage: ./setup-nginx-ssl.sh

set -e

DOMAIN="taz.infra.ori3com.cloud"

echo "🔐 Configuration nginx avec SSL pour OpenWebUI"
echo "=============================================="
echo "Domaine: $DOMAIN"
echo ""

# Installer nginx
echo "📦 Installation de nginx..."
apt-get update
apt-get install -y nginx

# Créer le répertoire pour les certificats
echo "📁 Création du répertoire des certificats..."
mkdir -p /etc/nginx/ssl

# Générer un certificat SSL auto-signé pour nginx
echo "🔐 Génération du certificat SSL auto-signé..."
openssl req -x509 -newkey rsa:4096 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt -days 365 -nodes \
    -subj "/C=FR/ST=France/L=Paris/O=OpenWebUI/OU=IT/CN=$DOMAIN" \
    -addext "subjectAltName=DNS:$DOMAIN,DNS:localhost,IP:127.0.0.1,IP:135.181.25.208"

# Définir les permissions
chmod 644 /etc/nginx/ssl/nginx.crt
chmod 600 /etc/nginx/ssl/nginx.key

# Créer la configuration nginx
echo "🔧 Configuration de nginx..."
cat > /etc/nginx/sites-available/openwebui << EOF
server {
    listen 80;
    server_name $DOMAIN;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN;

    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # Proxy vers OpenWebUI
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
EOF

# Activer le site
echo "🔗 Activation du site nginx..."
ln -sf /etc/nginx/sites-available/openwebui /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Tester la configuration
echo "🧪 Test de la configuration nginx..."
nginx -t

# Redémarrer nginx
echo "🚀 Redémarrage de nginx..."
systemctl restart nginx
systemctl enable nginx

echo ""
echo "✅ Configuration nginx avec SSL terminée!"
echo "🌐 Accédez à OpenWebUI: https://$DOMAIN"
echo "⚠️  Note: Le navigateur affichera un avertissement de sécurité (normal pour un certificat auto-signé)"
echo ""
echo "📋 Test de connexion:"
echo "   curl -k https://$DOMAIN/api/version"
echo ""
echo "📋 Commandes utiles:"
echo "   - Voir les logs nginx: journalctl -u nginx -f"
echo "   - Redémarrer nginx: systemctl restart nginx"
echo "   - Statut nginx: systemctl status nginx"
