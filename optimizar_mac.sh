#!/bin/bash

# ==============================================================================
# Script de Optimización y Limpieza de Caché para macOS
# ==============================================================================
# Instrucciones de uso:
# 1. Dale permisos de ejecución al archivo con: chmod +x optimizar_mac.sh
# 2. Ejecútalo con: ./optimizar_mac.sh
# ==============================================================================

echo "------------------------------------------------"
# 1. Liberar memoria RAM activa
echo "[1/4] Liberando memoria RAM inactiva y caché de disco..."
sudo purge

echo "------------------------------------------------"
# 2. Limpiar la caché de fuentes (Fonts)
echo "[2/4] Limpiando la caché de fuentes del sistema..."
atsutil databases -remove

echo "------------------------------------------------"
# 3. Abrir la carpeta de caché de usuario para revisión manual
echo "[3/4] Abriendo la carpeta de caché de usuario en Finder..."
open ~/Library/Caches

echo "------------------------------------------------"
# 4. Desactivar animaciones de las ventanas en Finder
echo "[4/4] Desactivando animaciones pesadas de ventana en Finder..."
defaults write com.apple.finder DisableAllAnimations -bool true

echo "------------------------------------------------"
echo "¡Proceso completado!"
echo "Nota: Se recomienda reiniciar tu MacBook para aplicar todos los cambios de forma óptima."
echo "------------rTech Technologies------------------"