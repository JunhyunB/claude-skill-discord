#!/usr/bin/env bash
# claude-skill-discord installer
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BIN_DIR="${HOME}/.local/bin"
SKILL_DIR="${HOME}/.claude/commands/sc"
WEBHOOK_ENV="${HOME}/.claude/discord-webhook.env"

echo "============================================"
echo "  claude-skill-discord installer"
echo "============================================"
echo ""

# --- 1. discord-notify CLI ---
echo "[1/3] Installing discord-notify CLI..."
mkdir -p "$BIN_DIR"
cp "$SCRIPT_DIR/discord-notify" "$BIN_DIR/discord-notify"
chmod +x "$BIN_DIR/discord-notify"

# Check PATH
if ! echo "$PATH" | grep -q "$BIN_DIR"; then
  echo ""
  echo "  Warning: $BIN_DIR is not in your PATH."
  echo "  Add the following to your shell config:"
  echo ""
  echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
  echo ""
fi
echo "  Done: $BIN_DIR/discord-notify"

# --- 2. Skill file ---
echo ""
echo "[2/3] Installing Claude Code skill..."
mkdir -p "$SKILL_DIR"
cp "$SCRIPT_DIR/discord.md" "$SKILL_DIR/discord.md"
echo "  Done: $SKILL_DIR/discord.md"

# --- 3. Webhook setup ---
echo ""
echo "[3/3] Discord Webhook setup..."

if [[ -f "$WEBHOOK_ENV" ]]; then
  echo "  Existing config found: $WEBHOOK_ENV"
  read -rp "  Overwrite? (y/N): " overwrite
  if [[ "${overwrite,,}" != "y" ]]; then
    echo "  Skipped (keeping existing config)"
    echo ""
    echo "============================================"
    echo "  Installation complete!"
    echo ""
    echo "  Test: discord-notify \"Hello from Claude!\""
    echo "============================================"
    exit 0
  fi
fi

echo ""
echo "  A Discord Webhook URL is required."
echo "  How to get one:"
echo "    Server Settings > Integrations > Webhooks > New Webhook > Copy URL"
echo ""
read -rp "  Webhook URL: " webhook_url

if [[ -z "$webhook_url" ]]; then
  echo "  No URL entered. Set it up later:"
  echo "     echo 'DISCORD_WEBHOOK_URL=https://...' > $WEBHOOK_ENV"
elif [[ "$webhook_url" != https://discord.com/api/webhooks/* ]]; then
  echo "  This doesn't look like a valid Discord Webhook URL."
  echo "     Expected: https://discord.com/api/webhooks/ID/TOKEN"
  read -rp "  Save anyway? (y/N): " force
  if [[ "${force,,}" != "y" ]]; then
    echo "  Skipped. Set it up later."
    webhook_url=""
  fi
fi

if [[ -n "$webhook_url" ]]; then
  mkdir -p "$(dirname "$WEBHOOK_ENV")"
  echo "DISCORD_WEBHOOK_URL=$webhook_url" > "$WEBHOOK_ENV"
  chmod 600 "$WEBHOOK_ENV"
  echo "  Saved: $WEBHOOK_ENV (permissions: 600)"
fi

echo ""
echo "============================================"
echo "  Installation complete!"
echo ""
echo "  Test:  discord-notify \"Hello from Claude!\""
echo "  Help:  discord-notify"
echo ""
echo "  In Claude Code, just say:"
echo "    \"Send this to Discord\" -> /sc:discord runs automatically"
echo "============================================"
