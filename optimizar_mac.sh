#!/bin/bash
# ==============================================================================
# Optimizar Mac - mantenimiento seguro para macOS
# No desactiva ni modifica las animaciones del Finder.
# ==============================================================================

set -u

APP_NAME="Optimizar Mac"
CONFIG_DIR="${HOME}/.config/optimizar_mac"
CONFIG_FILE="${CONFIG_DIR}/config"
LOG_DIR="${HOME}/Library/Logs"
LOG_FILE="${LOG_DIR}/optimizar_mac.log"

mkdir -p "$CONFIG_DIR" "$LOG_DIR" || {
  echo "No se pudieron crear las carpetas de configuración o registro."
  exit 1
}

# Opciones activadas por defecto. Son tareas puntuales, no ajustes permanentes.
PURGE_ENABLED="true"
FONTS_ENABLED="true"
CACHE_FOLDER_ENABLED="true"

log() {
  local message="$1"
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$message" | tee -a "$LOG_FILE"
}

pause() {
  echo
  read -r -p "Pulsa Intro para continuar..."
}

is_macos() {
  [[ "$(uname -s)" == "Darwin" ]]
}

load_config() {
  if [[ -f "$CONFIG_FILE" ]]; then
    # El archivo lo genera este script; no se ejecuta como código.
    while IFS='=' read -r key value; do
      case "$key" in
        PURGE_ENABLED) [[ "$value" == "true" || "$value" == "false" ]] && PURGE_ENABLED="$value" ;;
        FONTS_ENABLED) [[ "$value" == "true" || "$value" == "false" ]] && FONTS_ENABLED="$value" ;;
        CACHE_FOLDER_ENABLED) [[ "$value" == "true" || "$value" == "false" ]] && CACHE_FOLDER_ENABLED="$value" ;;
      esac
    done < "$CONFIG_FILE"
  fi
}

save_config() {
  {
    printf 'PURGE_ENABLED=%s\n' "$PURGE_ENABLED"
    printf 'FONTS_ENABLED=%s\n' "$FONTS_ENABLED"
    printf 'CACHE_FOLDER_ENABLED=%s\n' "$CACHE_FOLDER_ENABLED"
  } > "$CONFIG_FILE" || {
    log "ERROR: no se pudo guardar la configuración."
    return 1
  }
  log "Configuración guardada."
}

check_command() {
  command -v "$1" >/dev/null 2>&1
}

run_purge() {
  echo
  log "Iniciando limpieza de memoria/caché inactiva (purge)."
  if ! check_command purge; then
    log "ERROR: el comando 'purge' no está disponible en este macOS."
    return 1
  fi

  echo "macOS puede solicitar la contraseña de administrador."
  if sudo purge; then
    log "OK: purge terminó correctamente."
    return 0
  else
    log "ERROR: purge falló o fue cancelado."
    return 1
  fi
}

clean_fonts() {
  echo
  log "Solicitada limpieza de bases de datos de fuentes."
  if ! check_command atsutil; then
    log "ERROR: 'atsutil' no está disponible en este macOS."
    return 1
  fi

  echo "Esta operación elimina bases de datos de caché de fuentes; macOS puede reconstruirlas."
  read -r -p "¿Continuar? [s/N]: " answer
  case "$answer" in
    s|S|si|SI|Sí|sí)
      if atsutil databases -remove; then
        log "OK: atsutil terminó correctamente."
        return 0
      else
        log "ERROR: atsutil no pudo completar la operación."
        return 1
      fi
      ;;
    *)
      log "Limpieza de fuentes cancelada por el usuario."
      return 1
      ;;
  esac
}

open_cache_folder() {
  local cache_dir="${HOME}/Library/Caches"
  log "Solicitada apertura de ${cache_dir}."
  if [[ ! -d "$cache_dir" ]]; then
    log "ERROR: no existe la carpeta ${cache_dir}."
    return 1
  fi
  if ! check_command open; then
    log "ERROR: el comando 'open' no está disponible."
    return 1
  fi
  if open "$cache_dir"; then
    log "OK: carpeta de caché abierta en Finder. No se ha borrado ningún archivo."
    return 0
  else
    log "ERROR: no se pudo abrir la carpeta de caché."
    return 1
  fi
}

run_selected() {
  local ran=0
  echo
  echo "Ejecutando las tareas activadas..."
  if [[ "$PURGE_ENABLED" == "true" ]]; then
    run_purge
    ran=1
  else
    log "Omitido: purge está desactivado en la configuración."
  fi

  if [[ "$FONTS_ENABLED" == "true" ]]; then
    clean_fonts
    ran=1
  else
    log "Omitido: limpieza de fuentes desactivada en la configuración."
  fi

  if [[ "$CACHE_FOLDER_ENABLED" == "true" ]]; then
    open_cache_folder
    ran=1
  else
    log "Omitido: apertura de carpeta Caches desactivada en la configuración."
  fi

  if [[ "$ran" -eq 0 ]]; then
    log "No había tareas activadas."
  else
    log "Finalizó la ejecución de las tareas seleccionadas."
  fi
}

toggle_setting() {
  local label="$1"
  local current="$2"
  local key="$3"
  local new_value
  if [[ "$current" == "true" ]]; then new_value="false"; else new_value="true"; fi
  case "$key" in
    purge) PURGE_ENABLED="$new_value" ;;
    fonts) FONTS_ENABLED="$new_value" ;;
    cache) CACHE_FOLDER_ENABLED="$new_value" ;;
  esac
  log "Opción '${label}' cambiada a ${new_value}."
  save_config
}

restore_preferences() {
  echo
  echo "RESTAURAR PREFERENCIAS"
  echo "Este script no desactiva ni cambia las animaciones."
  echo "Si una ejecución anterior dejó DisableAllAnimations=true, se puede quitar"
  echo "esa preferencia para volver al comportamiento animado predeterminado."
  echo
  local animation_value=""
  if defaults read com.apple.finder DisableAllAnimations >/dev/null 2>&1; then
    animation_value="$(defaults read com.apple.finder DisableAllAnimations 2>/dev/null || true)"
  fi

  if [[ "$animation_value" == "1" || "$animation_value" == "true" ]]; then
    read -r -p "Se detectó la opción que desactiva animaciones. ¿Quitarla? [s/N]: " answer
    case "$answer" in
      s|S|si|SI|Sí|sí)
        if defaults delete com.apple.finder DisableAllAnimations 2>/dev/null; then
          log "OK: se eliminó DisableAllAnimations; Finder vuelve a su comportamiento predeterminado con animaciones."
        else
          log "ERROR: no se pudo restaurar la preferencia de animaciones."
        fi
        ;;
      *)
        log "Restauración de animaciones cancelada."
        ;;
    esac
  else
    log "No se detectó DisableAllAnimations=true; no se modificó ninguna preferencia del Finder."
  fi

  echo
  read -r -p "¿Restaurar también las tareas del menú a su configuración inicial? [s/N]: " answer
  case "$answer" in
    s|S|si|SI|Sí|sí)
      PURGE_ENABLED="true"
      FONTS_ENABLED="true"
      CACHE_FOLDER_ENABLED="true"
      save_config
      log "Configuración del menú restaurada a sus valores iniciales."
      ;;
    *)
      log "Se mantuvo la configuración actual del menú."
      ;;
  esac
}

show_status() {
  printf '\nEstado de las tareas:\n'
  printf '  1. Liberar memoria/caché inactiva: %s\n' "$PURGE_ENABLED"
  printf '  2. Limpiar caché de fuentes:       %s\n' "$FONTS_ENABLED"
  printf '  3. Abrir carpeta Caches:           %s\n' "$CACHE_FOLDER_ENABLED"
  printf '\nAnimaciones del Finder: este script NO las desactiva.\n'
}

show_menu() {
  clear
  echo "=================================================="
  echo "              OPTIMIZAR MAC"
  echo "=================================================="
  echo "macOS: $(sw_vers -productVersion 2>/dev/null || echo 'versión desconocida')"
  echo "Registro: $LOG_FILE"
  echo "--------------------------------------------------"
  echo "1. Ejecutar tareas activadas"
  echo "2. Liberar memoria/caché inactiva ahora"
  echo "3. Limpiar caché de fuentes ahora"
  echo "4. Abrir carpeta de caché de usuario"
  echo "5. Activar/desactivar tareas"
  echo "6. Restaurar preferencias originales"
  echo "7. Ver registro de operaciones"
  echo "8. Salir"
  echo "--------------------------------------------------"
  echo "Las animaciones del Finder se mantienen ACTIVADAS."
  echo "=================================================="
}

settings_menu() {
  while true; do
    clear
    echo "===== ACTIVAR / DESACTIVAR TAREAS ====="
    show_status
    echo
    echo "1. Alternar liberación de memoria"
    echo "2. Alternar limpieza de fuentes"
    echo "3. Alternar apertura de carpeta Caches"
    echo "4. Volver"
    read -r -p "Selecciona una opción: " choice
    case "$choice" in
      1) toggle_setting "purge" "$PURGE_ENABLED" purge ;;
      2) toggle_setting "fonts" "$FONTS_ENABLED" fonts ;;
      3) toggle_setting "carpeta Caches" "$CACHE_FOLDER_ENABLED" cache ;;
      4) return ;;
      *) echo "Opción no válida."; sleep 1 ;;
    esac
  done
}

main() {
  if ! is_macos; then
    echo "ERROR: este script está diseñado exclusivamente para macOS."
    exit 1
  fi

  load_config
  log "Inicio de ${APP_NAME}. macOS $(sw_vers -productVersion 2>/dev/null || echo desconocido)."

  while true; do
    show_menu
    read -r -p "Selecciona una opción [1-8]: " choice
    case "$choice" in
      1) run_selected; pause ;;
      2) run_purge; pause ;;
      3) clean_fonts; pause ;;
      4) open_cache_folder; pause ;;
      5) settings_menu ;;
      6) restore_preferences; pause ;;
      7) clear; echo "===== REGISTRO DE OPERACIONES ====="; cat "$LOG_FILE"; pause ;;
      8) log "Salida del programa."; echo "¡Hasta luego!"; exit 0 ;;
      *) echo "Opción no válida."; sleep 1 ;;
    esac
  done
}

main "$@"
