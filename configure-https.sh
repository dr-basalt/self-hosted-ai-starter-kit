#!/bin/bash

# Script de configuration HTTPS manuelle pour OpenWebUI
# Usage: ./configure-https.sh

set -e

echo "🔐 Configuration HTTPS manuelle pour OpenWebUI"
echo "=============================================="

# Vérifier que les certificats existent
if [ ! -f "/app/certs/cert.pem" ] || [ ! -f "/app/certs/key.pem" ]; then
    echo "❌ Certificats SSL non trouvés. Exécutez d'abord: ./setup-self-signed-ssl.sh"
    exit 1
fi

echo "✅ Certificats SSL trouvés"

# Arrêter OpenWebUI
echo "⏸️  Arrêt d'OpenWebUI..."
cd /root/self-hosted-ai-starter-kit
docker compose stop openwebui

# Créer un script de démarrage personnalisé pour OpenWebUI avec HTTPS
echo "🔧 Configuration du démarrage HTTPS..."
cat > /root/self-hosted-ai-starter-kit/start-openwebui-https.sh << 'EOF'
#!/bin/bash

# Script de démarrage OpenWebUI avec HTTPS
cd /app/open-webui/backend

# Démarrer OpenWebUI avec SSL
exec uvicorn open_webui.main:app \
    --host 0.0.0.0 \
    --port 8080 \
    --ssl-certfile /app/certs/cert.pem \
    --ssl-keyfile /app/certs/key.pem \
    --reload
EOF

chmod +x /root/self-hosted-ai-starter-kit/start-openwebui-https.sh

# Modifier le docker-compose pour utiliser le script personnalisé
echo "📝 Modification du docker-compose.yml..."
sed -i 's|"bash start.sh"|"bash /app/start-openwebui-https.sh"|' /root/self-hosted-ai-starter-kit/docker-compose.yml

# Redémarrer OpenWebUI
echo "🚀 Redémarrage d'OpenWebUI avec HTTPS..."
docker compose up -d openwebui

echo ""
echo "✅ Configuration HTTPS terminée!"
echo "🌐 Accédez à OpenWebUI: https://taz.infra.ori3com.cloud"
echo "⚠️  Note: Le navigateur affichera un avertissement de sécurité (normal pour un certificat auto-signé)"
echo ""
echo "📋 Test de connexion:"
echo "   curl -k https://taz.infra.ori3com.cloud/api/version"
