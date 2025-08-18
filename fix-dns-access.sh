#!/bin/bash

# Script pour résoudre le problème d'accès DNS
# Usage: ./fix-dns-access.sh

set -e

IP_ADDRESS="135.181.25.208"
DOMAIN="taz.infra.ori3com.cloud"

echo "🌐 Résolution du problème d'accès DNS"
echo "====================================="
echo "IP du serveur: $IP_ADDRESS"
echo "Domaine: $DOMAIN"
echo ""

# Vérifier si le domaine résout
echo "🔍 Vérification de la résolution DNS..."
if nslookup $DOMAIN > /dev/null 2>&1; then
    echo "✅ Le domaine $DOMAIN résout correctement"
    RESOLVED_IP=$(nslookup $DOMAIN | grep -A1 "Name:" | tail -1 | awk '{print $2}')
    echo "   IP résolue: $RESOLVED_IP"
    
    if [ "$RESOLVED_IP" = "$IP_ADDRESS" ]; then
        echo "✅ Le domaine pointe vers la bonne IP"
    else
        echo "⚠️  Le domaine pointe vers une IP différente: $RESOLVED_IP"
        echo "   IP attendue: $IP_ADDRESS"
    fi
else
    echo "❌ Le domaine $DOMAIN ne résout pas"
fi

echo ""
echo "🔧 Solutions disponibles:"
echo ""

echo "📋 Option 1: Accès direct par IP (recommandé)"
echo "   URL: https://$IP_ADDRESS"
echo "   Avantages: Fonctionne immédiatement"
echo "   Inconvénients: Pas de nom de domaine"
echo ""

echo "📋 Option 2: Configuration DNS locale"
echo "   Ajoutez dans /etc/hosts (Linux/Mac) ou C:\Windows\System32\drivers\etc\hosts (Windows):"
echo "   $IP_ADDRESS $DOMAIN"
echo ""

echo "📋 Option 3: Configuration DNS public"
echo "   Configurez un enregistrement A dans votre DNS:"
echo "   $DOMAIN -> $IP_ADDRESS"
echo ""

echo "📋 Option 4: Utilisation d'un service DNS dynamique"
echo "   Services: No-IP, DuckDNS, etc."
echo ""

echo "🚀 Test d'accès par IP:"
echo "   curl -k https://$IP_ADDRESS/api/version"
echo ""

echo "🌐 URLs de test:"
echo "   - Par IP: https://$IP_ADDRESS"
echo "   - Par domaine: https://$DOMAIN (si DNS configuré)"
echo ""

# Test d'accès par IP
echo "🧪 Test d'accès par IP..."
if curl -k -s https://$IP_ADDRESS/api/version > /dev/null 2>&1; then
    echo "✅ Accès par IP fonctionne"
    echo "   Réponse: $(curl -k -s https://$IP_ADDRESS/api/version)"
else
    echo "❌ Accès par IP échoue"
fi
