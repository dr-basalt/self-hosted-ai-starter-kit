#!/bin/bash

# Script de test pour OpenWebUI
echo "🧪 Test d'OpenWebUI et de ses services..."

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour tester un endpoint
test_endpoint() {
    local name=$1
    local url=$2
    local method=${3:-GET}
    local data=${4:-""}
    
    echo -n "Testing $name... "
    
    if [ "$method" = "POST" ] && [ -n "$data" ]; then
        response=$(curl -s -w "%{http_code}" -X $method -H "Content-Type: application/json" -d "$data" "$url")
    else
        response=$(curl -s -w "%{http_code}" -X $method "$url")
    fi
    
    http_code="${response: -3}"
    body="${response%???}"
    
    if [ "$http_code" -eq 200 ] || [ "$http_code" -eq 201 ]; then
        echo -e "${GREEN}✅ OK${NC}"
    else
        echo -e "${RED}❌ FAILED (HTTP $http_code)${NC}"
        echo "Response: $body"
    fi
}

# Attendre que les services démarrent
echo "⏳ Attente du démarrage des services..."
sleep 30

# Test 1: Qdrant
echo -e "\n${YELLOW}1. Test de Qdrant${NC}"
test_endpoint "Qdrant Health" "http://localhost:6333/health"

# Test 2: OpenWebUI
echo -e "\n${YELLOW}2. Test d'OpenWebUI${NC}"
test_endpoint "OpenWebUI Health" "http://localhost:3000/api/v1/health"

# Test 3: API Mémoire
echo -e "\n${YELLOW}3. Test de l'API Mémoire${NC}"
test_endpoint "Memory API Search" "http://localhost:5001/memory/search" "POST" '{"query":"test","limit":1}'

# Test 4: n8n
echo -e "\n${YELLOW}4. Test de n8n${NC}"
test_endpoint "n8n Health" "http://localhost:5678/healthz"

# Test 5: Ollama (via votre serveur distant)
echo -e "\n${YELLOW}5. Test d'Ollama${NC}"
test_endpoint "Ollama Models" "http://taz.infra.ori3com.cloud:11434/api/tags"

# Test 6: Webhook n8n
echo -e "\n${YELLOW}6. Test du Webhook n8n${NC}"
test_endpoint "n8n Webhook" "http://localhost:5678/webhook/openwebui-chat" "POST" '{"message":"Test message","model":"phi3:3.8b"}'

# Test 7: Modèles disponibles
echo -e "\n${YELLOW}7. Vérification des modèles${NC}"
echo "Modèles disponibles sur Ollama:"
curl -s "http://taz.infra.ori3com.cloud:11434/api/tags" | jq -r '.models[].name' 2>/dev/null || echo "Impossible de récupérer la liste des modèles"

# Test 8: Collection Qdrant
echo -e "\n${YELLOW}8. Test de la collection Qdrant${NC}"
collections=$(curl -s "http://localhost:6333/collections" | jq -r '.collections[].name' 2>/dev/null)
if echo "$collections" | grep -q "openwebui_memory"; then
    echo -e "${GREEN}✅ Collection openwebui_memory trouvée${NC}"
else
    echo -e "${YELLOW}⚠️  Collection openwebui_memory non trouvée (sera créée au premier usage)${NC}"
fi

# Résumé
echo -e "\n${YELLOW}📊 Résumé des tests${NC}"
echo "Services testés:"
echo "- Qdrant (port 6333)"
echo "- OpenWebUI (port 3000)"
echo "- API Mémoire (port 5001)"
echo "- n8n (port 5678)"
echo "- Ollama distant (taz.infra.ori3com.cloud:11434)"
echo "- Webhook n8n"

echo -e "\n${GREEN}🎉 Tests terminés !${NC}"
echo "Pour accéder à OpenWebUI: http://localhost:3000"
echo "Pour accéder à n8n: http://localhost:5678"
