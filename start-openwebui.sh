#!/bin/bash

# Script de démarrage pour OpenWebUI avec mémoire et STT/TTS

echo "Démarrage d'OpenWebUI avec mémoire et STT/TTS..."

# Configuration automatique d'OpenWebUI
echo "Configuration automatique d'OpenWebUI..."
# Les paramètres sont maintenant configurés via les variables d'environnement
echo "✅ Paramètres STT/TTS configurés via variables d'environnement"

# Démarrer l'API de mémoire en arrière-plan
echo "Démarrage de l'API de mémoire..."
python3 /app/openwebui-memory.py &
MEMORY_PID=$!

# Attendre que l'API de mémoire soit prête
sleep 5

# Démarrer OpenWebUI
echo "Démarrage d'OpenWebUI..."
cd /app/open-webui/backend
python3 -m uvicorn open_webui.main:app --host 0.0.0.0 --port 3000 --ssl-certfile /app/certs/cert.pem --ssl-keyfile /app/certs/key.pem

# Attendre la fin des processus
wait $MEMORY_PID
