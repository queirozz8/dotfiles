#!/usr/bin/env bash
set -euo pipefail

# Remove dados recriáveis e informa a variação líquida de espaço livre.
# Arquivos em uso podem ser ignorados; feche os navegadores para liberar mais.
initial_free=$(df -B1 --output=avail "$HOME" | tail -n 1 | tr -d ' ')
report_freed() {
  local exit_code=$? current_free delta
  trap - EXIT
  current_free=$(df -B1 --output=avail "$HOME" | tail -n 1 | tr -d ' ') || current_free="$initial_free"
  delta=$((current_free - initial_free))
  if (( delta >= 0 )); then
    awk -v bytes="$delta" 'BEGIN { printf "Espaço liberado (líquido): %.2f GiB\n", bytes / 1073741824 }'
  else
    awk -v bytes="$delta" 'BEGIN { printf "Espaço livre diminuiu durante a execução: %.2f GiB\n", -bytes / 1073741824 }'
  fi
  exit "$exit_code"
}
trap report_freed EXIT

remove_cache_contents() {
  local path="$1"
  if [[ -d "$path" ]]; then
    if find "$path" -depth -mindepth 1 -delete 2>/dev/null; then
      printf 'Limpo: %s\n' "$path"
    else
      printf 'Aviso: alguns arquivos em uso foram ignorados em %s\n' "$path" >&2
    fi
  fi
}

for path in \
  "$HOME/.cache/BraveSoftware/Brave-Browser/Default/Cache" \
  "$HOME/.cache/BraveSoftware/Brave-Browser/Default/Code Cache" \
  "$HOME/.cache/BraveSoftware/Brave-Origin/Default/Cache" \
  "$HOME/.cache/BraveSoftware/Brave-Origin/Default/Code Cache" \
  "$HOME/.cache/mozilla/firefox" \
  "$HOME/.cache/thumbnails" \
  "$HOME/.cache/pip" \
  "$HOME/.cache/libdnf5"; do
  remove_cache_contents "$path"
done

sudo -v
sudo journalctl --vacuum-time=14d
sudo dnf clean all

if command -v docker >/dev/null 2>&1 && timeout 5 docker info >/dev/null 2>&1; then
  docker builder prune --all --force
else
  printf 'Docker indisponível; cache de build não foi alterado.\n'
fi
