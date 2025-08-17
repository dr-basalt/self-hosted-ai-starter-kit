#!/bin/bash

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Self-Hosted AI Starter Kit${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Fonction pour vérifier si une commande existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Fonction pour installer Docker si nécessaire
install_docker() {
    if ! command_exists docker; then
        print_message "Installation de Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        sudo usermod -aG docker $USER
        rm get-docker.sh
        print_warning "Docker installé. Veuillez vous reconnecter ou redémarrer pour que les changements prennent effet."
        exit 1
    else
        print_message "Docker est déjà installé"
    fi
}

# Fonction pour installer Docker Compose v2
install_docker_compose() {
    if ! command_exists docker-compose; then
        print_message "Installation de Docker Compose v2..."
        sudo apt-get update
        sudo apt-get install -y docker-compose-v2
    else
        print_message "Docker Compose est déjà installé"
    fi
}

# Fonction pour installer Python et pip
install_python() {
    if ! command_exists python3; then
        print_message "Installation de Python 3..."
        sudo apt-get update
        sudo apt-get install -y python3 python3-pip
    else
        print_message "Python 3 est déjà installé"
    fi
}

# Fonction pour créer le fichier .env
create_env_file() {
    if [ ! -f .env ]; then
        if [ -f env.example ]; then
            print_message "Copie de env.example vers .env..."
            cp env.example .env
        else
            print_warning "Fichier .env.example non trouvé. Création d'un fichier .env basique..."
            cat > .env << EOF
# Configuration de la base de données PostgreSQL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=password
POSTGRES_DB=n8n

# Clés de chiffrement N8N
N8N_ENCRYPTION_KEY=your-encryption-key-here
N8N_USER_MANAGEMENT_JWT_SECRET=your-jwt-secret-here

# Configuration Ollama
OLLAMA_HOST=ollama:11434
EOF
        fi
    else
        print_message "Fichier .env existe déjà"
    fi
}

# Fonction pour afficher l'aide
show_help() {
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  cpu     - Lancer avec le profil CPU"
    echo "  gpu     - Lancer avec le profil GPU NVIDIA"
    echo "  gpu-amd - Lancer avec le profil GPU AMD"
    echo "  help    - Afficher cette aide"
    echo ""
    echo "Exemples:"
    echo "  $0 cpu     # Lance avec CPU"
    echo "  $0 gpu     # Lance avec GPU NVIDIA"
    echo "  $0 gpu-amd # Lance avec GPU AMD"
}

# Fonction principale
main() {
    print_header
    
    # Vérification des arguments
    if [ $# -eq 0 ]; then
        print_error "Aucun argument fourni"
        show_help
        exit 1
    fi
    
    case "$1" in
        "help"|"-h"|"--help")
            show_help
            exit 0
            ;;
        "cpu"|"gpu"|"gpu-amd")
            PROFILE="$1"
            ;;
        *)
            print_error "Option invalide: $1"
            show_help
            exit 1
            ;;
    esac
    
    print_message "Configuration pour le profil: $PROFILE"
    
    # Installation des dépendances
    print_message "Vérification et installation des dépendances..."
    install_docker
    install_docker_compose
    install_python
    
    # Création du fichier .env
    create_env_file
    
    # Vérification que Docker est en cours d'exécution
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker n'est pas en cours d'exécution. Veuillez démarrer Docker."
        exit 1
    fi
    
    # Construction et lancement
    print_message "Construction et lancement des services..."
    
    case "$PROFILE" in
        "cpu")
            docker-compose --profile cpu up -d
            ;;
        "gpu")
            if ! command_exists nvidia-smi; then
                print_error "NVIDIA GPU non détecté. Veuillez installer les drivers NVIDIA."
                exit 1
            fi
            docker-compose --profile gpu-nvidia up -d
            ;;
        "gpu-amd")
            if [ ! -e "/dev/kfd" ] || [ ! -e "/dev/dri" ]; then
                print_error "AMD GPU non détecté. Veuillez installer les drivers AMD ROCm."
                exit 1
            fi
            docker-compose --profile gpu-amd up -d
            ;;
    esac
    
    print_message "Services lancés avec succès!"
    print_message "OpenWebUI sera disponible sur: http://localhost:3000"
    print_message "N8N sera disponible sur: http://localhost:5678"
    print_message "Qdrant sera disponible sur: http://localhost:6333"
    print_message "Ollama sera disponible sur: http://localhost:11434"
    
    print_message "Pour voir les logs: docker-compose logs -f"
    print_message "Pour arrêter: docker-compose down"
}

# Exécution du script principal
main "$@"
