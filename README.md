# claude-skill-discord

[Claude Code](https://claude.ai/code) skill for sending messages, embeds, and files to Discord via webhooks.

> **한국어 문서**: [README.ko.md](./README.ko.md)

## Features

- **Text messages** — Simple text with Markdown support
- **Embeds** — Rich embeds with title, description, color, fields, timestamps
- **File attachments** — Single or multiple files (up to 10, max 25MB each)
- **Raw JSON** — Full Discord webhook API access for complex layouts
- **Session handoff** — Hand off Claude Code CLI sessions to Discord bots
- **Custom identity** — Override bot name and avatar per message
- **Thread support** — Send to specific Discord threads

## Requirements

- [Claude Code CLI](https://claude.ai/code)
- `curl`, `jq` (pre-installed on most systems)
- Discord webhook URL (see below)

## Creating a Discord Webhook

### Step 1: Open Server Settings

Click your Discord server name → **Server Settings**

### Step 2: Integrations

Click **Integrations** in the left sidebar

### Step 3: Create Webhook

1. Click **Webhooks**
2. Click **New Webhook**
3. Configure:
   - **Name**: Choose a display name (e.g., "Claude Notify")
   - **Channel**: Select the target channel
4. Click **Copy Webhook URL**

> URL format: `https://discord.com/api/webhooks/123456789/ABCdef...`
>
> Treat this URL like a password — anyone with it can post to your channel.

### Tip: Create a dedicated channel (recommended)

A separate notification channel keeps things organized:

1. Click **+** in the channel list → **Text Channel**
2. Name it `#claude-notify` or `#bot-alerts`
3. Attach the webhook to this channel

## Installation

```bash
git clone https://github.com/JunhyunB/claude-skill-discord.git
cd claude-skill-discord
./install.sh
```

The installer will:
1. Copy `discord-notify` CLI to `~/.local/bin/`
2. Copy the skill file to `~/.claude/commands/sc/`
3. Prompt you to enter your Discord webhook URL

### Verify

```bash
discord-notify "Hello from Claude Code!"
```

## Usage

### Inside Claude Code (natural language)

Just ask Claude:
- "디스코드로 결과 보내줘" / "Send results to Discord"
- "학습 곡선 이미지 디스코드에 공유해" / "Share the training curve on Discord"
- "이 세션 디스코드 봇한테 넘겨줘" / "Hand off this session to Discord"

Claude Code will automatically use the `/sc:discord` skill.

### CLI direct usage

```bash
# Text message
discord-notify "Hello world"

# Embed with title, description, color
discord-notify --embed "Title" "Description" 5793266

# Single file
discord-notify --file ./result.png "Training results"

# Multiple files (up to 10)
discord-notify --files loss.png acc.csv conf.png -- "All results"

# Raw JSON (full webhook API)
discord-notify --rich '{"embeds":[{"title":"Custom","fields":[{"name":"k","value":"v","inline":true}]}]}'

# Session handoff (Claude Code → Discord bot)
discord-notify --handoff "Summary of current work"

# Pipe input
echo "piped content" | discord-notify
```

### Global options (prepend to any command)

```bash
--name "Bot Name"     # Custom sender name
--avatar "URL"        # Custom avatar image
--thread "ThreadID"   # Send to specific thread
--tts                 # Text-to-speech
```

Example:
```bash
discord-notify --name "Experiment Bot" --embed "Done" "Accuracy: 87.3%" 5793266
```

## Example: ML experiment results

```bash
discord-notify --name "Lab Bot" --rich '{
  "embeds": [{
    "title": "Experiment Complete",
    "color": 5793266,
    "fields": [
      {"name": "Model", "value": "ResNet-50", "inline": true},
      {"name": "Accuracy", "value": "87.3 ± 0.2%", "inline": true},
      {"name": "Baseline", "value": "85.1%", "inline": true}
    ],
    "footer": {"text": "seeds: 42,43,44 | p < 0.01"}
  }]
}'
```

## Configuration

Webhook URL is stored at `~/.claude/discord-webhook.env`:

```
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/YOUR_ID/YOUR_TOKEN
```

To change it:
```bash
echo 'DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/...' > ~/.claude/discord-webhook.env
chmod 600 ~/.claude/discord-webhook.env
```

## Limits

| Limit | Value |
|-------|-------|
| Message length | 2,000 chars (auto-truncated) |
| Embed description | 4,096 chars (auto-truncated) |
| File size | 25 MB (100 MB on Nitro servers) |
| Files per message | 10 |
| Embeds per message | 10 |
| Rate limit | 5/sec, 30/min |

## Uninstall

```bash
./uninstall.sh
```

## Security

- Webhook URL is stored locally at `~/.claude/discord-webhook.env` with `chmod 600`
- **Never commit your webhook URL** — `.gitignore` excludes `*.env` files
- The webhook URL grants write access to a Discord channel. Treat it like a password.
- If your URL is leaked, regenerate it in Discord: Server Settings → Integrations → Webhooks

## License

MIT
