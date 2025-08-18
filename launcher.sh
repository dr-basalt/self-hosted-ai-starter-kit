#!/bin/bash

# Launcher pour Self-Hosted AI Starter Kit
# Automatise l'installation et le lancement des services

set -e

echo "🚀 Self-Hosted AI Starter Kit Launcher"
echo "======================================"

# Fonction pour afficher l'aide
show_help() {
    echo "Usage: $0 [PROFILE] [OPTIONS]"
    echo ""
    echo "Profils disponibles:"
    echo "  cpu          - Lancement avec profil CPU"
    echo "  gpu          - Lancement avec profil GPU NVIDIA"
    echo "  gpu-amd      - Lancement avec profil GPU AMD"
    echo ""
    echo "Options:"
    echo "  --help       - Afficher cette aide"
    echo "  --setup      - Configuration initiale complète"
    echo "  --configure  - Configuration des modèles et services"
    echo "  --letsencrypt - Configuration Let's Encrypt"
    echo ""
    echo "Exemples:"
    echo "  $0 cpu                    # Lancement CPU simple"
    echo "  $0 gpu --setup            # Setup complet GPU"
    echo "  $0 cpu --configure        # Configuration des modèles"
}

# Fonction pour la configuration initiale
setup_initial() {
    echo "📦 Configuration initiale..."
    
    # Mise à jour du système
    echo "  🔄 Mise à jour du système..."
    apt-get update
    
    # Installation de Docker Compose v2
    echo "  🐳 Installation de Docker Compose v2..."
    apt-get install -y docker-compose-v2
    
    # Installation de Python et pip
    echo "  🐍 Installation de Python et pip..."
    apt-get install -y python3-pip
    
    # Installation de certbot pour Let's Encrypt
    echo "  🔐 Installation de certbot..."
    apt-get install -y certbot
    
    # Copie du fichier d'environnement
    echo "  📋 Configuration de l'environnement..."
    if [ ! -f .env ]; then
        cp env.example .env
        echo "    ✅ Fichier .env créé depuis env.example"
    else
        echo "    ℹ️  Fichier .env existe déjà"
    fi
    
    echo "✅ Configuration initiale terminée!"
}

# Fonction pour configurer les modèles et services
configure_services() {
    echo "🔧 Configuration des services..."
    
    # Attendre que les services soient prêts
    echo "  ⏳ Attente du démarrage des services..."
    sleep 30
    
    # Télécharger les modèles selon le profil
    case "$PROFILE" in
        "cpu")
            echo "  📥 Téléchargement des modèles CPU..."
            docker compose exec -T ollama ollama pull llama2
            docker compose exec -T ollama ollama pull phi3
            docker compose exec -T ollama ollama pull gemma2
            ;;
        "gpu")
            echo "  📥 Téléchargement des modèles GPU..."
            docker compose exec -T ollama ollama pull llama2
            docker compose exec -T ollama ollama pull phi3
            docker compose exec -T ollama ollama pull gemma2
            ;;
        "gpu-amd")
            echo "  📥 Téléchargement des modèles GPU AMD..."
            docker compose exec -T ollama ollama pull llama2
            docker compose exec -T ollama ollama pull phi3
            docker compose exec -T ollama ollama pull gemma2
            ;;
    esac
    
    # Configuration automatique des modèles via l'API
    echo "  ⚙️  Configuration automatique des modèles..."
    if command -v python3 &> /dev/null; then
        python3 configure-models.py
    else
        echo "    ⚠️  Python3 non disponible, configuration manuelle requise"
    fi
    
    echo "✅ Configuration des services terminée!"
}

# Fonction pour configurer Let's Encrypt
setup_letsencrypt() {
    echo "🔐 Configuration Let's Encrypt..."
    
    # Vérifier que le domaine est configuré
    if [ -z "$LETSENCRYPT_DOMAIN" ]; then
        echo "  ⚠️  Variable LETSENCRYPT_DOMAIN non définie dans .env"
        echo "  📝 Veuillez configurer LETSENCRYPT_DOMAIN et LETSENCRYPT_EMAIL dans .env"
        return 1
    fi
    
    # Exécuter le script Let's Encrypt
    if [ -f "setup-letsencrypt.sh" ]; then
        chmod +x setup-letsencrypt.sh
        ./setup-letsencrypt.sh "$LETSENCRYPT_DOMAIN" "$LETSENCRYPT_EMAIL"
    else
        echo "  ❌ Script setup-letsencrypt.sh non trouvé"
        return 1
    fi
    
    echo "✅ Configuration Let's Encrypt terminée!"
}

# Variables globales
PROFILE=""
SETUP=false
CONFIGURE=false
LETSENCRYPT=false

# Parsing des arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        cpu|gpu|gpu-amd)
            PROFILE="$1"
            shift
            ;;
        --setup)
            SETUP=true
            shift
            ;;
        --configure)
            CONFIGURE=true
            shift
            ;;
        --letsencrypt)
            LETSENCRYPT=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo "❌ Option inconnue: $1"
            show_help
            exit 1
            ;;
    esac
done

# Vérification du profil
if [ -z "$PROFILE" ]; then
    echo "❌ Profil non spécifié"
    show_help
    exit 1
fi

# Charger les variables d'environnement
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Configuration initiale si demandée
if [ "$SETUP" = true ]; then
    setup_initial
fi

# Lancement des services
echo "🚀 Lancement des services avec le profil: $PROFILE"

# Arrêter les services existants
echo "  ⏸️  Arrêt des services existants..."
docker compose down

# Lancer les services selon le profil
case "$PROFILE" in
    "cpu")
        echo "  🔧 Lancement en mode CPU..."
        docker compose up -d postgres n8n ollama qdrant openwebui
        ;;
    "gpu")
        echo "  🔧 Lancement en mode GPU NVIDIA..."
        docker compose up -d postgres n8n ollama qdrant openwebui
        ;;
    "gpu-amd")
        echo "  🔧 Lancement en mode GPU AMD..."
        docker compose up -d postgres n8n ollama qdrant openwebui
        ;;
esac

# Configuration des services si demandée
if [ "$CONFIGURE" = true ]; then
    configure_services
fi

# Configuration Let's Encrypt si demandée
if [ "$LETSENCRYPT" = true ]; then
    setup_letsencrypt
fi

# Affichage du statut
echo ""
echo "📊 Statut des services:"
docker compose ps

echo ""
echo "🌐 Accès aux services:"
echo "  - OpenWebUI: http://localhost:3000 (ou https://$LETSENCRYPT_DOMAIN:3000 si Let's Encrypt configuré)"
echo "  - N8N: http://localhost:5678"
echo "  - Ollama API: http://localhost:11434"
echo "  - Qdrant: http://localhost:6333"
echo ""
echo "📋 Commandes utiles:"
echo "  - Voir les logs: docker compose logs -f [service]"
echo "  - Arrêter: docker compose down"
echo "  - Redémarrer: docker compose restart [service]"
echo ""
echo "✅ Lancement terminé!"