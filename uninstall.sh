#!/usr/bin/env bash
# claude-skill-discord uninstaller
set -euo pipefail

echo "Removing claude-skill-discord..."

rm -f "$HOME/.local/bin/discord-notify"
echo "  Removed: discord-notify CLI"

rm -f "$HOME/.claude/commands/sc/discord.md"
echo "  Removed: skill file"

if [[ -f "$HOME/.claude/discord-webhook.env" ]]; then
  read -rp "  Also delete webhook config? ($HOME/.claude/discord-webhook.env) (y/N): " del
  if [[ "${del,,}" == "y" ]]; then
    rm -f "$HOME/.claude/discord-webhook.env"
    echo "  Removed: webhook config"
  else
    echo "  Kept: webhook config"
  fi
fi

echo ""
echo "Uninstall complete."
