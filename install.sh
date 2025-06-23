#!/bin/bash

echo "========================================"
echo "  Salesforce API Updater - Installer"
echo "========================================"
echo ""

echo "[1/3] Verificando Node.js..."
if ! command -v node &> /dev/null; then
    echo "ERROR: Node.js no está instalado."
    echo "Por favor instala Node.js desde: https://nodejs.org/"
    exit 1
fi
echo "✓ Node.js detectado ($(node --version))"

echo ""
echo "[2/3] Instalando dependencias..."
if ! npm install; then
    echo "ERROR: Falló la instalación de dependencias"
    exit 1
fi
echo "✓ Dependencias instaladas"

echo ""
echo "[3/3] Verificando Salesforce CLI (opcional)..."
if ! command -v sfdx &> /dev/null; then
    echo "ADVERTENCIA: Salesforce CLI no detectado"
    echo "Para usar la función de deploy, instala SFDX CLI:"
    echo "npm install @salesforce/cli --global"
else
    echo "✓ Salesforce CLI detectado ($(sfdx --version))"
fi

echo ""
echo "========================================"
echo "  ¡Instalación completada!"
echo "========================================"
echo ""
echo "Para ejecutar la aplicación:"
echo "  npm start"
echo ""
echo "Para construir ejecutable:"
echo "  npm run build-mac    # macOS"
echo "  npm run build-linux  # Linux"
echo "" 