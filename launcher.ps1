# Self-Hosted AI Starter Kit Launcher pour Windows
# Usage: .\launcher.ps1 [cpu|gpu|gpu-amd]

param(
    [Parameter(Position=0)]
    [ValidateSet("cpu", "gpu", "gpu-amd", "help")]
    [string]$Profile = "help"
)

# Couleurs pour les messages
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Blue"
$White = "White"

# Fonction pour afficher les messages
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor $Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Red
}

function Write-Header {
    Write-Host "================================" -ForegroundColor $Blue
    Write-Host "  Self-Hosted AI Starter Kit" -ForegroundColor $Blue
    Write-Host "================================" -ForegroundColor $Blue
}

# Fonction pour vérifier si une commande existe
function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Fonction pour installer Docker Desktop
function Install-Docker {
    if (-not (Test-Command "docker")) {
        Write-Info "Installation de Docker Desktop..."
        Write-Warning "Veuillez télécharger et installer Docker Desktop depuis https://www.docker.com/products/docker-desktop/"
        Write-Warning "Après l'installation, redémarrez votre ordinateur et relancez ce script."
        exit 1
    }
    else {
        Write-Info "Docker est déjà installé"
    }
}

# Fonction pour installer Docker Compose
function Install-DockerCompose {
    if (-not (Test-Command "docker-compose")) {
        Write-Info "Installation de Docker Compose..."
        Write-Warning "Docker Compose devrait être inclus avec Docker Desktop. Si ce n'est pas le cas, veuillez l'installer manuellement."
    }
    else {
        Write-Info "Docker Compose est déjà installé"
    }
}

# Fonction pour installer Python
function Install-Python {
    if (-not (Test-Command "python")) {
        Write-Info "Installation de Python..."
        Write-Warning "Veuillez télécharger et installer Python depuis https://www.python.org/downloads/"
        Write-Warning "Assurez-vous de cocher 'Add Python to PATH' lors de l'installation."
        exit 1
    }
    else {
        Write-Info "Python est déjà installé"
    }
}

# Fonction pour créer le fichier .env
function Create-EnvFile {
    if (-not (Test-Path ".env")) {
        if (Test-Path "env.example") {
            Write-Info "Copie de env.example vers .env..."
            Copy-Item "env.example" ".env"
        }
        else {
            Write-Warning "Fichier .env.example non trouvé. Création d'un fichier .env basique..."
            @"
# Configuration de la base de données PostgreSQL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=password
POSTGRES_DB=n8n

# Clés de chiffrement N8N
N8N_ENCRYPTION_KEY=your-encryption-key-here
N8N_USER_MANAGEMENT_JWT_SECRET=your-jwt-secret-here

# Configuration Ollama
OLLAMA_HOST=ollama:11434
"@ | Out-File -FilePath ".env" -Encoding UTF8
        }
    }
    else {
        Write-Info "Fichier .env existe déjà"
    }
}

# Fonction pour afficher l'aide
function Show-Help {
    Write-Host "Usage: .\launcher.ps1 [OPTION]" -ForegroundColor $White
    Write-Host ""
    Write-Host "Options:" -ForegroundColor $White
    Write-Host "  cpu     - Lancer avec le profil CPU" -ForegroundColor $White
    Write-Host "  gpu     - Lancer avec le profil GPU NVIDIA" -ForegroundColor $White
    Write-Host "  gpu-amd - Lancer avec le profil GPU AMD" -ForegroundColor $White
    Write-Host "  help    - Afficher cette aide" -ForegroundColor $White
    Write-Host ""
    Write-Host "Exemples:" -ForegroundColor $White
    Write-Host "  .\launcher.ps1 cpu     # Lance avec CPU" -ForegroundColor $White
    Write-Host "  .\launcher.ps1 gpu     # Lance avec GPU NVIDIA" -ForegroundColor $White
    Write-Host "  .\launcher.ps1 gpu-amd # Lance avec GPU AMD" -ForegroundColor $White
}

# Fonction principale
function Main {
    Write-Header
    
    if ($Profile -eq "help") {
        Show-Help
        return
    }
    
    Write-Info "Configuration pour le profil: $Profile"
    
    # Installation des dépendances
    Write-Info "Vérification et installation des dépendances..."
    Install-Docker
    Install-DockerCompose
    Install-Python
    
    # Création du fichier .env
    Create-EnvFile
    
    # Vérification que Docker est en cours d'exécution
    try {
        docker info | Out-Null
    }
    catch {
        Write-Error "Docker n'est pas en cours d'exécution. Veuillez démarrer Docker Desktop."
        exit 1
    }
    
    # Construction et lancement
    Write-Info "Construction et lancement des services..."
    
    switch ($Profile) {
        "cpu" {
            docker-compose --profile cpu up -d
        }
        "gpu" {
            if (-not (Test-Command "nvidia-smi")) {
                Write-Error "NVIDIA GPU non détecté. Veuillez installer les drivers NVIDIA."
                exit 1
            }
            docker-compose --profile gpu-nvidia up -d
        }
        "gpu-amd" {
            Write-Warning "Support GPU AMD non testé sur Windows. Utilisation du profil CPU."
            docker-compose --profile cpu up -d
        }
    }
    
    Write-Info "Services lancés avec succès!"
    Write-Info "OpenWebUI sera disponible sur: http://localhost:3000"
    Write-Info "N8N sera disponible sur: http://localhost:5678"
    Write-Info "Qdrant sera disponible sur: http://localhost:6333"
    Write-Info "Ollama sera disponible sur: http://localhost:11434"
    
    Write-Info "Pour voir les logs: docker-compose logs -f"
    Write-Info "Pour arrêter: docker-compose down"
}

# Exécution du script principal
Main
