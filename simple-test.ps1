Write-Host "Test du Launcher" -ForegroundColor Green

# Test des fichiers
$files = @("launcher.ps1", "env.example", "docker-compose.yml", "requirements.txt")
foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "OK: $file existe" -ForegroundColor Green
    } else {
        Write-Host "ERREUR: $file manquant" -ForegroundColor Red
    }
}

# Test du launcher
Write-Host "Test du launcher..." -ForegroundColor Yellow
try {
    $output = .\launcher.ps1 help
    Write-Host "OK: Launcher fonctionne" -ForegroundColor Green
} catch {
    Write-Host "ERREUR: Probleme avec le launcher" -ForegroundColor Red
}

Write-Host "Test termine!" -ForegroundColor Green
