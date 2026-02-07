# claude-skill-discord

[Claude Code](https://claude.ai/code)에서 Discord 웹훅으로 메시지, 임베드, 파일을 전송하는 스킬입니다.

> **English version**: [README.md](./README.md)

## 주요 기능

- **텍스트 메시지** — Markdown 지원
- **임베드** — 제목, 설명, 색상, 필드, 타임스탬프
- **파일 첨부** — 단일/다중 파일 (최대 10개, 개당 25MB)
- **원시 JSON** — Discord Webhook API 전체 접근
- **세션 핸드오프** — Claude Code CLI 세션을 Discord 봇으로 인수인계
- **커스텀 봇 이름/아바타** — 메시지마다 변경 가능
- **스레드 전송** — 특정 스레드에 전송

## 사전 준비

- [Claude Code CLI](https://claude.ai/code) 설치
- `curl`, `jq` (대부분의 OS에 기본 설치됨)
- Discord Webhook URL (아래 만드는 법 참고)

## Discord Webhook 만드는 법

### 1단계: 서버 설정 열기

Discord 서버 이름 클릭 → **서버 설정** 선택

### 2단계: 연동 메뉴

좌측 메뉴에서 **연동** (Integrations) 클릭

### 3단계: 웹후크 만들기

1. **웹후크** (Webhooks) 클릭
2. **새 웹후크** (New Webhook) 클릭
3. 설정:
   - **이름**: 원하는 봇 이름 (예: "Claude Notify")
   - **채널**: 메시지를 받을 채널 선택
4. **웹후크 URL 복사** 클릭

> URL 형식: `https://discord.com/api/webhooks/123456789/ABCdef...`
>
> 이 URL은 비밀번호처럼 취급하세요. 이 URL을 가진 누구나 해당 채널에 메시지를 보낼 수 있습니다.

### 팁: 전용 채널 만들기 (권장)

알림 전용 채널을 따로 만들면 관리가 편합니다:

1. 채널 목록에서 **+** → **텍스트 채널** 생성
2. 이름: `#claude-notify` 또는 `#bot-alerts`
3. 이 채널에 웹후크를 연결

## 설치

```bash
git clone https://github.com/JunhyunB/claude-skill-discord.git
cd claude-skill-discord
./install.sh
```

설치 프로그램이 하는 일:
1. `discord-notify` CLI를 `~/.local/bin/`에 복사
2. 스킬 파일을 `~/.claude/commands/sc/`에 복사
3. Discord Webhook URL 입력 안내

### 설치 확인

```bash
discord-notify "Hello from Claude Code!"
```

Discord 채널에 메시지가 도착하면 성공입니다.

## 사용법

### Claude Code 안에서 (자연어)

Claude에게 말하면 자동으로 `/sc:discord` 스킬이 실행됩니다:
- "디스코드로 결과 보내줘"
- "학습 곡선 이미지 디스코드에 공유해"
- "이 세션 디스코드 봇한테 넘겨줘"

### CLI 직접 사용

```bash
# 텍스트 메시지
discord-notify "안녕하세요"

# 임베드 (제목 + 설명 + 색상)
discord-notify --embed "제목" "설명 내용" 5793266

# 파일 1개
discord-notify --file ./result.png "학습 결과"

# 파일 여러 개 (최대 10개)
discord-notify --files loss.png acc.csv conf.png -- "결과 모음"

# 원시 JSON (고급 임베드)
discord-notify --rich '{"embeds":[{"title":"커스텀","fields":[{"name":"k","value":"v","inline":true}]}]}'

# 세션 핸드오프 (Claude Code → Discord 봇)
discord-notify --handoff "현재 작업 요약"

# 파이프 입력
echo "파이프 내용" | discord-notify
```

### 글로벌 옵션 (다른 옵션 앞에 추가)

```bash
--name "봇이름"       # 커스텀 발신자 이름
--avatar "URL"        # 커스텀 아바타 이미지
--thread "스레드ID"   # 특정 스레드에 전송
--tts                 # 음성 읽기
```

예시:
```bash
discord-notify --name "실험봇" --embed "완료" "Accuracy: 87.3%" 5793266
```

## 예시: ML 실험 결과 전송

```bash
discord-notify --name "Lab Bot" --rich '{
  "embeds": [{
    "title": "🔬 실험 완료",
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

## 설정

Webhook URL은 `~/.claude/discord-webhook.env`에 저장됩니다:

```
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/YOUR_ID/YOUR_TOKEN
```

변경하려면:
```bash
echo 'DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/...' > ~/.claude/discord-webhook.env
chmod 600 ~/.claude/discord-webhook.env
```

## 제한사항

| 항목 | 제한 |
|------|------|
| 메시지 길이 | 2,000자 (자동 잘림) |
| 임베드 설명 | 4,096자 (자동 잘림) |
| 파일 크기 | 25MB (Nitro 서버 100MB) |
| 파일 수 | 메시지당 10개 |
| 임베드 수 | 메시지당 10개 |
| Rate limit | 초당 5회, 분당 30회 |

## 제거

```bash
./uninstall.sh
```

## 보안

- Webhook URL은 `~/.claude/discord-webhook.env`에 로컬 저장 (권한: `600`)
- **Webhook URL을 절대 커밋하지 마세요** — `.gitignore`가 `*.env` 파일을 차단합니다
- Webhook URL은 해당 채널에 쓰기 권한을 부여합니다. 비밀번호처럼 관리하세요.
- URL이 유출되면 Discord에서 재생성: 서버 설정 → 연동 → 웹후크 → URL 재생성

## 라이선스

MIT
