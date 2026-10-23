#!/usr/bin/env bash
set -euo pipefail

# Remove apenas dados recriáveis do cache do usuário e limita journals antigos.
# Feche os navegadores antes de executar para liberar o máximo de espaço.

remove_cache_contents() {
  local path="$1"
  if [[ -d "$path" ]]; then
    find "$path" -mindepth 1 -maxdepth 1 -delete
    printf 'Limpo: %s\n' "$path"
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

df -h "$HOME"
