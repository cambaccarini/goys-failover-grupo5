#!/usr/bin/env bash
# Renderiza los .rsc de configs/ sustituyendo los tokens __NOMBRE__ por los secretos
# definidos en configs/secrets.env. Genera configs/<ROUTER>.rendered.rsc (ignorado por Git).
# Uso: ./configs/render.sh [ROUTER ...]     (sin argumentos: los 7 routers)
set -euo pipefail
cd "$(dirname "$0")"

[ -f secrets.env ] || { echo "ERROR: falta configs/secrets.env (copiar de secrets.example.env)"; exit 1; }

TOKENS=(SNMP_COMMUNITY OSPF_MD5_KEY VRRP_KEY BGP_KEY_ISP1 BGP_KEY_ISP2 NETADMIN_PASSWORD MONITOR_PASSWORD)
declare -A VAL
# Se lee como texto (NO se hace source): un valor con |, &, $ o ; no puede ejecutarse como comando.
while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in ''|'#'*) continue;; esac
  key="${line%%=*}"; val="${line#*=}"
  for t in "${TOKENS[@]}"; do [ "$key" = "$t" ] && VAL[$t]="$val"; done
done < secrets.env

for t in "${TOKENS[@]}"; do
  v="${VAL[$t]:-}"
  [ -n "$v" ] || { echo "ERROR: $t vacío o ausente en secrets.env"; exit 1; }
  # Juego de caracteres seguro para valores sin comillas en RouterOS
  [[ "$v" =~ ^[A-Za-z0-9._@%+:-]+$ ]] || { echo "ERROR: $t contiene caracteres no permitidos (usar solo A-Z a-z 0-9 . _ @ % + : -)"; exit 1; }
done

ROUTERS=("$@")
[ ${#ROUTERS[@]} -gt 0 ] || ROUTERS=(EDGE ISP-1 ISP-2 CORE-1 CORE-2 DIST-1 DIST-2)

for r in "${ROUTERS[@]}"; do
  out="$r.rendered.rsc"
  sed_args=()
  for t in "${TOKENS[@]}"; do
    sed_args+=(-e "s|__${t}__|${VAL[$t]}|g")
  done
  sed "${sed_args[@]}" "$r.rsc" > "$out"
  if grep -v '^[[:space:]]*#' "$out" | grep -qE '__[A-Z0-9_]+__'; then
    echo "ERROR: quedaron tokens sin sustituir en $out"; rm -f "$out"; exit 1
  fi
  echo "OK  $out"
done
echo "Recordar: subir el .rendered.rsc al router, /import, y borrarlo (no versionar)."
