#!/bin/bash

# Script pour télécharger et installer le certificat SSL
# Usage: ./install-certificate.sh

set -e

DOMAIN="taz.infra.ori3com.cloud"
CERT_FILE="taz.infra.ori3com.cloud.crt"

echo "🔐 Téléchargement du certificat SSL pour $DOMAIN"
echo "================================================"
echo ""

# Télécharger le certificat depuis le serveur
echo "📥 Téléchargement du certificat..."
scp root@taz.infra.ori3com.cloud:/etc/nginx/ssl/nginx.crt ./$CERT_FILE

if [ -f "$CERT_FILE" ]; then
    echo "✅ Certificat téléchargé: $CERT_FILE"
    echo ""
    echo "🔧 Instructions d'installation:"
    echo ""
    echo "📱 Pour Windows (Chrome/Edge):"
    echo "   1. Double-cliquez sur le fichier: $CERT_FILE"
    echo "   2. Cliquez sur 'Installer le certificat'"
    echo "   3. Sélectionnez 'Ordinateur local'"
    echo "   4. Sélectionnez 'Autorités de certification racines de confiance'"
    echo "   5. Cliquez sur 'Suivant' puis 'Terminer'"
    echo "   6. Redémarrez votre navigateur"
    echo ""
    echo "🍎 Pour macOS (Chrome/Safari):"
    echo "   1. Double-cliquez sur le fichier: $CERT_FILE"
    echo "   2. Ajoutez le certificat à 'Système'"
    echo "   3. Redémarrez votre navigateur"
    echo ""
    echo "🐧 Pour Linux (Chrome/Firefox):"
    echo "   1. Importez le certificat dans les paramètres de votre navigateur"
    echo "   2. Redémarrez votre navigateur"
    echo ""
    echo "🌐 Après installation, accédez à: https://$DOMAIN"
    echo ""
    echo "📋 Test de connexion:"
    echo "   curl -k https://$DOMAIN/api/version"
else
    echo "❌ Erreur lors du téléchargement du certificat"
    exit 1
fi
