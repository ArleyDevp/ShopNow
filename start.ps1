# ============================================
# ShopNow - Iniciar Backend + Flutter
# ============================================
# Este script inicia el servidor de autenticacion (backend)
# y luego lanza la app Flutter. Al cerrar Flutter, el backend
# se detiene automaticamente.
# ============================================

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$backendDir = Join-Path $scriptDir "backend"

Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "  ShopNow - Iniciando entorno de desarrollo" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan

# Verificar que node exista
if (!(Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Node.js no esta instalado o no esta en el PATH." -ForegroundColor Red
    exit 1
}

# Verificar que flutter exista
if (!(Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Flutter no esta instalado o no esta en el PATH." -ForegroundColor Red
    exit 1
}

# Verificar dependencias del backend
if (!(Test-Path (Join-Path $backendDir "node_modules"))) {
    Write-Host "Instalando dependencias del backend (npm install)..." -ForegroundColor Yellow
    npm install --prefix $backendDir | Out-Null
    Write-Host "Dependencias instaladas." -ForegroundColor Green
}

# Iniciar backend en segundo plano
Write-Host "Iniciando backend en puerto 3000..." -ForegroundColor Yellow
$backendProcess = Start-Process -FilePath "node" -ArgumentList "index.js" -WorkingDirectory $backendDir -PassThru -WindowStyle Hidden
Write-Host "Backend iniciado (PID: $($backendProcess.Id))" -ForegroundColor Green

# Esperar a que el backend responda
Start-Sleep -Seconds 3

# Verificar que el backend este en linea
try {
    $test = Invoke-RestMethod -Uri "http://localhost:3000/api/auth/neon/signup" -Method Post -ContentType "application/json" -Body @{ email="test@test.com"; password="Test.006"; name="Test" } | ConvertTo-Json
    Write-Host "Backend respondiendo correctamente." -ForegroundColor Green
} catch {
    Write-Host "ADVERTENCIA: El backend no responde en http://localhost:3000" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Iniciando Flutter..." -ForegroundColor Yellow
Write-Host "==============================================" -ForegroundColor Cyan

try {
    flutter run
} finally {
    # Detener backend al salir de Flutter
    Write-Host ""
    Write-Host "Deteniendo backend..." -ForegroundColor Yellow
    if ($backendProcess -and $backendProcess.Handle) {
        Stop-Process -Id $backendProcess.Id -Force -ErrorAction SilentlyContinue
        Write-Host "Backend detenido." -ForegroundColor Green
    }
}
