#!/bin/bash

# Script pour améliorer la compatibilité SSL avec les navigateurs
# Usage: ./fix-ssl-browser.sh

set -e

DOMAIN="taz.infra.ori3com.cloud"

echo "🔧 Amélioration de la compatibilité SSL pour les navigateurs"
echo "============================================================"
echo "Domaine: $DOMAIN"
echo ""

# Arrêter nginx
echo "⏸️  Arrêt de nginx..."
systemctl stop nginx

# Générer un nouveau certificat avec des paramètres plus compatibles
echo "🔐 Génération d'un nouveau certificat SSL plus compatible..."
openssl req -x509 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt -days 365 -nodes \
    -subj "/C=FR/ST=France/L=Paris/O=OpenWebUI/OU=IT/CN=$DOMAIN" \
    -addext "subjectAltName=DNS:$DOMAIN,DNS:localhost,IP:127.0.0.1,IP:135.181.25.208,IP:135.181.25.208" \
    -sha256

# Définir les permissions
chmod 644 /etc/nginx/ssl/nginx.crt
chmod 600 /etc/nginx/ssl/nginx.key

# Améliorer la configuration nginx
echo "🔧 Amélioration de la configuration nginx..."
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
    
    # Configuration SSL moderne et compatible
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # Headers de sécurité
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-XSS-Protection "1; mode=block" always;

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
        
        # Buffer settings
        proxy_buffering off;
        proxy_request_buffering off;
    }
}
EOF

# Tester la configuration
echo "🧪 Test de la configuration nginx..."
nginx -t

# Redémarrer nginx
echo "🚀 Redémarrage de nginx..."
systemctl start nginx

echo ""
echo "✅ Configuration SSL améliorée!"
echo ""
echo "🌐 Accédez à OpenWebUI: https://$DOMAIN"
echo ""
echo "⚠️  IMPORTANT: Le navigateur affichera toujours un avertissement de sécurité"
echo "   car c'est un certificat auto-signé. C'est normal et attendu."
echo ""
echo "🔧 Pour contourner l'avertissement dans votre navigateur:"
echo "   1. Cliquez sur 'Avancé' ou 'Advanced'"
echo "   2. Cliquez sur 'Continuer vers taz.infra.ori3com.cloud (non sécurisé)'"
echo "   3. Ou ajoutez une exception de sécurité"
echo ""
echo "📋 Test de connexion:"
echo "   curl -k https://$DOMAIN/api/version"
echo ""
echo "🔐 Pour un certificat valide (Let's Encrypt):"
echo "   1. Configurez le DNS: $DOMAIN -> 135.181.25.208"
echo "   2. Exécutez: ./setup-ssl.sh"
