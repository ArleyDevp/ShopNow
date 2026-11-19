@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo ==============================================
echo   ShopNow - Iniciando entorno de desarrollo
echo ==============================================

:: Verificar node
where node >nul 2>&1
if errorlevel 1 (
    echo ERROR: Node.js no esta instalado o no esta en el PATH.
    pause
    exit /b 1
)

:: Verificar flutter
where flutter >nul 2>&1
if errorlevel 1 (
    echo ERROR: Flutter no esta instalado o no esta en el PATH.
    pause
    exit /b 1
)

:: Instalar dependencias del backend si faltan
if not exist "backend\node_modules" (
    echo Instalando dependencias del backend...
    npm install --prefix backend >nul 2>&1
    echo Dependencias instaladas.
)

:: Iniciar backend en segundo plano
echo Iniciando backend en puerto 3000...
start "ShopNowBackend" /b node backend/index.js
timeout /t 3 >nul

echo.
echo Iniciando Flutter...
echo ==============================================

:: Ejecutar flutter run (bloqueante)
flutter run

:: Detener backend al salir de Flutter
echo.
echo Deteniendo backend...
taskkill /FI "WINDOWTITLE eq ShopNowBackend" /F >nul 2>&1
echo Backend detenido.

endlocal
