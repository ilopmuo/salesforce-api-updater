@echo off
echo ========================================
echo   Salesforce API Updater - Installer
echo ========================================
echo.

echo [1/3] Verificando Node.js...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Node.js no esta instalado.
    echo Por favor instala Node.js desde: https://nodejs.org/
    pause
    exit /b 1
)
echo ✓ Node.js detectado

echo.
echo [2/3] Instalando dependencias...
call npm install
if %errorlevel% neq 0 (
    echo ERROR: Fallo la instalacion de dependencias
    pause
    exit /b 1
)
echo ✓ Dependencias instaladas

echo.
echo [3/3] Verificando Salesforce CLI (opcional)...
sfdx --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ADVERTENCIA: Salesforce CLI no detectado
    echo Para usar la funcion de deploy, instala SFDX CLI:
    echo npm install @salesforce/cli --global
) else (
    echo ✓ Salesforce CLI detectado
)

echo.
echo ========================================
echo   ¡Instalacion completada!
echo ========================================
echo.
echo Para ejecutar la aplicacion:
echo   npm start
echo.
echo Para construir ejecutable:
echo   npm run build-win
echo.
pause 