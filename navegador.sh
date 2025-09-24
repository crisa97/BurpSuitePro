#!/usr/bin/env bash
set -euo pipefail

# Uso:
# ./chromium_download_to_dir.sh "https://ejemplo/download?..." /ruta/a/carpeta_destino [TIMEOUT_S]
URL="${1:-}"
TARGET_DIR="${2:-}"
TIMEOUT_SECONDS="${3:-120}"

if [[ -z "$URL" || -z "$TARGET_DIR" ]]; then
  echo "Uso: $0 <URL> <CARPETA_DESTINO> [TIMEOUT_S]" >&2
  exit 2
fi

# Buscar binario de Chromium/Chrome disponible
CHROMIUM_BIN=""
for b in chromium chromium-browser google-chrome-stable google-chrome; do
  if command -v "$b" >/dev/null 2>&1; then
    CHROMIUM_BIN="$(command -v "$b")"
    break
  fi
done

if [[ -z "$CHROMIUM_BIN" ]]; then
  echo "Error: no se encontró Chromium/Chrome en PATH (busqué chromium, chromium-browser, google-chrome*)." >&2
  exit 3
fi

# Preparar carpeta destino
TARGET_DIR="$(readlink -f "$TARGET_DIR")"
mkdir -p "$TARGET_DIR"

# Crear perfil temporal
PROFILE_DIR="$(mktemp -d /tmp/chromeprofile.XXXXXX)"
mkdir -p "$PROFILE_DIR/Default"

# Asegurar limpieza si el script recibe señal
cleanup() {
  # intentar cerrar procesos asociados al profile
  if [[ -n "$PROFILE_DIR" && -d "$PROFILE_DIR" ]]; then
    echo "Cleanup: cerrando procesos que usan $PROFILE_DIR ..."
    # encontrar pids cuyo cmdline contenga el profile
    pids=$(pgrep -a -f -- "$PROFILE_DIR" | awk '{print $1}' || true)
    if [[ -n "$pids" ]]; then
      echo "PIDs encontrados: $pids"
      kill $pids 2>/dev/null || true
      sleep 1
      # forzar si queda alguno
      pids2=$(pgrep -a -f -- "$PROFILE_DIR" | awk '{print $1}' || true)
      if [[ -n "$pids2" ]]; then
        kill -9 $pids2 2>/dev/null || true
      fi
    fi
    rm -rf "$PROFILE_DIR"
  fi
}
trap cleanup EXIT INT TERM

# Escribir preferencias (JSON) para forzar carpeta de descargas y desactivar diálogo
cat > "$PROFILE_DIR/Default/Preferences" <<EOF
{
  "download": {
    "default_directory": "$(python -c "import json,sys; print(json.dumps('$TARGET_DIR')[1:-1])")",
    "prompt_for_download": false,
    "directory_upgrade": true,
    "extensions_to_open": ""
  },
  "profile": {
    "content_settings": {
      "pattern_pairs": {}
    }
  }
}
EOF

# Lanzar Chromium en un nuevo grupo de procesos con setsid (para aislar)
echo "Abriendo Chromium ($CHROMIUM_BIN) con perfil temporal..."
# puedes añadir --disable-gpu si obtienes muchos errores GPU; comentar si no lo quieres
setsid "$CHROMIUM_BIN" --user-data-dir="$PROFILE_DIR" --no-first-run --disable-extensions --disable-popup-blocking --disable-gpu "$URL" >/dev/null 2>&1 &
CH_PID=$!
sleep 1
echo "PID inicial de Chromium: $CH_PID"

# Registrar archivos existentes para compararlos
declare -A existing
while IFS= read -r -d '' f; do existing["$f"]=1; done < <(find "$TARGET_DIR" -maxdepth 1 -type f -print0)

downloaded_file=""
start_ts=$(date +%s)
end_ts=$((start_ts + TIMEOUT_SECONDS))
echo "Esperando descarga en '$TARGET_DIR' (timeout ${TIMEOUT_SECONDS}s)..."

while true; do
  now=$(date +%s)
  if (( now > end_ts )); then
    echo "Timeout: no se detectó una descarga completada en ${TIMEOUT_SECONDS}s." >&2
    break
  fi

  new_file=""
  # buscar archivos nuevos que no sean .crdownload
  while IFS= read -r -d '' f; do
    [[ -n "${existing[$f]:-}" ]] && continue
    # si está en progreso tendrá extensión .crdownload -> ignorar
    if [[ "$f" == *.crdownload ]]; then
      continue
    fi
    new_file="$f"
    break
  done < <(find "$TARGET_DIR" -maxdepth 1 -type f -print0 | sort -z)

  if [[ -n "$new_file" ]]; then
    # verificar que el archivo esté estable (no cambiando de tamaño)
    stable_checks=0
    last_size=-1
    for i in {1..4}; do
      size=$(stat -c%s "$new_file" 2>/dev/null || echo 0)
      if [[ "$size" -eq "$last_size" ]]; then
        ((stable_checks++))
      else
        stable_checks=0
      fi
      last_size=$size
      sleep 1
    done

    if (( stable_checks >= 2 )); then
      downloaded_file="$new_file"
      echo "Descarga completada: $downloaded_file"
      break
    fi
  fi

  sleep 1
done

# --------------------------
# Cerrar Chromium de forma robusta buscando procesos que usen el profile
# --------------------------
if [[ -n "$PROFILE_DIR" && -d "$PROFILE_DIR" ]]; then
  echo "Cerrando todos los procesos que usan el profile: $PROFILE_DIR"
  # buscar pids cuyo cmdline contenga el profile (excluye la propia búsqueda)
  pids=$(pgrep -a -f -- "$PROFILE_DIR" | awk '{print $1}' || true)
  if [[ -n "$pids" ]]; then
    echo "Intentando terminar (TERM) los procesos: $pids"
    kill $pids 2>/dev/null || true
    # esperar hasta 5s para que mueran voluntariamente
    for i in {1..5}; do
      sleep 1
      remaining=$(pgrep -a -f -- "$PROFILE_DIR" | awk '{print $1}' || true)
      if [[ -z "$remaining" ]]; then
        break
      fi
      echo "Aún activos: $remaining"
    done

    # forzar si queda alguno
    remaining=$(pgrep -a -f -- "$PROFILE_DIR" | awk '{print $1}' || true)
    if [[ -n "$remaining" ]]; then
      echo "Forzando kill -9 a: $remaining"
      kill -9 $remaining 2>/dev/null || true
    fi
  else
    echo "No se encontraron procesos ligados al profile $PROFILE_DIR"
  fi
fi

# Limpiar perfil temporal (trap EXIT también lo hace, pero lo intentamos aquí explícitamente)
rm -rf "$PROFILE_DIR" 2>/dev/null || true
# remover trap para no ejecutar cleanup dos veces (opcional)
trap - EXIT INT TERM

if [[ -n "$downloaded_file" ]]; then
  echo "Archivo guardado en: $downloaded_file"
  exit 0
else
  echo "No se obtuvo archivo." >&2
  exit 4
fi

