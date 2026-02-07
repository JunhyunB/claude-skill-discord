---
name: discord
description: "Send messages, embeds, and files to Discord via webhooks. Use for experiment notifications, session handoff, and team sharing."
category: utility
complexity: low
mcp-servers: []
personas: []
---

# /sc:discord - Discord Messaging & Session Handoff

## Triggers
- When you need to send a message to Discord
- When sharing experiment results to a Discord channel
- When sending task completion notifications to Discord
- **When handing off a session to a Discord bot** ("hand off to Discord", "let the bot continue")
- When the user says "send to Discord", "notify Discord", "share to channel", etc.

## Tool

Run `discord-notify` CLI (`~/.local/bin/discord-notify`) via Bash.

### Global Options (prepend to any command)
```bash
--name "BotName"       # Custom sender name
--avatar "URL"         # Custom avatar image
--thread "ThreadID"    # Send to specific thread
--tts                  # Enable text-to-speech
```

### Text Message
```bash
discord-notify "message content"
```

### Embed (title + description + color)
```bash
discord-notify --embed "Title" "Description" [color_code]
```
- Color codes (decimal, optional): purple `7506394` / green `5793266` / red `15548997` / blue `3447003` / orange `15105570`
- Use `\n` for line breaks in description
- Timestamp auto-included

### Single File
```bash
discord-notify --file /path/to/file.png "description"
```

### Multiple Files (up to 10)
```bash
discord-notify --files file1.png file2.csv file3.log -- "description"
```
- Message after `--` is optional
- Missing files are automatically skipped

### Raw JSON (advanced)
```bash
discord-notify --rich '{"embeds":[{"title":"Custom","fields":[{"name":"k","value":"v","inline":true}]}]}'
```
- Full Discord Webhook API spec support
- Use for complex embeds (fields, images, thumbnails, etc.)

### Session Handoff (Claude Code -> Discord bot)
```bash
discord-notify --handoff "summary of current work"
```
- Auto-extracts recent conversation from Claude Code session
- Saves session info to `~/.claude/last-handoff.json`
- Sends handoff notification to Discord

### Pipe Input
```bash
echo "content" | discord-notify
```

## Combination Examples

### Custom bot name + embed
```bash
discord-notify --name "Lab Bot" --embed "Experiment Done" "Accuracy: 87.3%" 5793266
```

### Send file to thread
```bash
discord-notify --thread "123456789" --file result.png "Result image"
```

### Multiple files + message
```bash
discord-notify --files loss_curve.png accuracy.csv confusion_matrix.png -- "Training results"
```

### Complex embed (fields + footer)
```bash
discord-notify --rich '{
  "embeds": [{
    "title": "Ablation Study Results",
    "color": 5793266,
    "fields": [
      {"name": "Baseline", "value": "85.1%", "inline": true},
      {"name": "Ours", "value": "87.3%", "inline": true},
      {"name": "Delta", "value": "+2.2%", "inline": true}
    ],
    "footer": {"text": "seeds: 42,43,44 | p < 0.01"}
  }]
}'
```

## Behavioral Flow

### Sending Messages
1. **Prepare content**: Compose message/embed content
2. **Choose format**: Pick appropriate format based on content
   - Short notification -> text message
   - Structured results (experiments, analysis) -> embed or `--rich`
   - Images, CSV, logs -> file attachment (`--file` / `--files`)
   - Complex layout -> `--rich` (raw JSON)
3. **Send**: Run `discord-notify`
4. **Confirm**: Notify user of successful delivery

### Session Handoff
1. **Write summary**: Summarize current work concisely
2. **Execute handoff**: Run `discord-notify --handoff "summary"`
3. **Confirm**: Notify user that session info was sent to Discord

## Limits
- Discord messages: 2,000 chars (auto-truncated)
- Embed description: 4,096 chars (auto-truncated)
- File size: 25 MB (100 MB on Nitro servers)
- Files per message: max 10
- Embeds per message: max 10
- Rate limit: 5/sec, 30/min
- Handoff: valid within 24 hours
- Webhook URL must be configured in `~/.claude/discord-webhook.env`
- Webhooks are **send-only** (no reading messages, reactions, buttons, etc.)
