#!/bin/bash

# Script de démarrage pour OpenWebUI avec mémoire et STT/TTS

echo "Démarrage d'OpenWebUI avec mémoire et STT/TTS..."

# Configuration automatique d'OpenWebUI
echo "Configuration automatique d'OpenWebUI..."
# Attendre que la base de données soit créée
sleep 10
python3 /app/configure-openwebui.py

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
