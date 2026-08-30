# 대본추출 — 영상 링크 하나로 대본 + 한국어 번역

Claude Code에서 쓰는 스킬입니다.
인스타 릴스, 유튜브, 유튜브 쇼츠, 틱톡 링크를 던지면 영상 속 말을 글로 바꿔서
**원본 대본**과 **자연스러운 한국어 번역**을 나란히 보여줍니다.

레퍼런스 릴스 분석, 해외 영상 벤치마킹, 강의 영상 정리에 쓰세요.

---

## 이렇게 씁니다

Claude Code를 열고 슬래시 명령으로:

```
/대본추출 https://www.instagram.com/reel/xxxxxxxx/
```

아니면 그냥 말로:

```
이 영상 뭐라고 하는지 대본 뽑아줘 https://youtube.com/shorts/xxxxxxxx
```

결과는 이렇게 나옵니다.

```
## 원본 대본

> Stop scrolling. This is the only productivity tip you'll ever need.
> ...

## 한국어 번역

> 잠깐만요. 생산성 팁은 이거 하나면 끝입니다.
> ...
```

한국어 영상이면 원본 대본만 나오고, 번역은 생략됩니다.

---

## 준비물

| 도구 | 하는 일 | 설치 안 돼 있으면 |
|------|---------|-------------------|
| Claude Code | 스킬을 실행하는 본체 | https://claude.com/claude-code |
| ffmpeg | 영상에서 소리만 분리 | 아래 설치 참고 |
| yt-dlp | 영상 다운로드 | 아래 설치 참고 |
| Whisper | 소리를 글자로 변환 (OpenAI 무료 공개 모델, 내 컴퓨터에서 돌아감) | 아래 설치 참고 |

Whisper는 API 키가 필요 없습니다. 인터넷 없이 내 컴퓨터에서 돌아가고, 비용도 0원입니다.

---

## 설치

### Mac — 한 줄

터미널을 열고 아래를 붙여넣으세요. 도구 3개 설치와 스킬 복사를 한 번에 합니다.

```bash
curl -fsSL https://raw.githubusercontent.com/gfmmmm/claude-video-transcript/main/install.sh | bash
```

Homebrew가 없다고 나오면 https://brew.sh 에서 먼저 설치한 뒤 다시 실행하세요.

직접 하고 싶다면:

```bash
brew install ffmpeg yt-dlp openai-whisper
git clone https://github.com/gfmmmm/claude-video-transcript.git ~/.claude/skills/대본추출
```

### Windows

1. Git for Windows 설치 — https://git-scm.com/download/win (Claude Code가 Git Bash를 씁니다)
2. Python 3.10 ~ 3.12 설치 — https://www.python.org/downloads/ (설치 화면에서 "Add Python to PATH" 체크)
3. PowerShell을 열고 순서대로:

```powershell
winget install Gyan.FFmpeg
winget install yt-dlp.yt-dlp
pip install openai-whisper
git clone https://github.com/gfmmmm/claude-video-transcript.git "$env:USERPROFILE\.claude\skills\대본추출"
```

`pip install openai-whisper`는 PyTorch를 같이 받아서 2GB 가까이 됩니다. 시간이 좀 걸리는 게 정상입니다.

### 설치 확인

터미널(Mac) 또는 PowerShell(Windows)에서 세 줄이 전부 응답하면 준비 끝입니다.

```bash
ffmpeg -version
yt-dlp --version
whisper --help
```

그다음 Claude Code를 새로 열고 `/대본추출`을 입력했을 때 "영상 URL을 공유해주세요"라고 물어보면 스킬이 잡힌 겁니다.

---

## 자주 막히는 곳

**처음 실행이 유난히 느려요**
Whisper 모델 파일(base 기준 약 140MB)을 첫 실행 때 한 번만 내려받습니다. 두 번째부터는 빠릅니다.

**인스타그램에서 "login required" 에러**
인스타는 로그인 없이 다운로드를 막을 때가 있습니다. Claude에게 "크롬 쿠키로 다시 시도해줘"라고 하면 브라우저에 로그인된 세션을 빌려서 다시 받습니다. 크롬에 인스타 로그인이 되어 있어야 합니다.

**비공개 영상 / 팔로워 공개 영상**
URL로는 못 받습니다. 영상 파일을 직접 다운로드해서 Claude에게 파일 경로를 주세요. 파일부터는 똑같이 진행됩니다.

**yt-dlp 에러가 자꾸 나요**
플랫폼이 페이지 구조를 바꾸면 yt-dlp도 업데이트해야 합니다.
Mac은 `brew upgrade yt-dlp`, Windows는 `pip install -U yt-dlp` 또는 `winget upgrade yt-dlp.yt-dlp`.

**Mac에서 pip 설치가 "externally-managed-environment"로 막혀요**
Mac은 pip 대신 위의 brew 경로를 쓰세요. brew가 whisper 전용 Python 환경을 따로 만들어줍니다.

**Mac에서 "ffmpeg is already installed from homebrew-ffmpeg/ffmpeg" 에러**
ffmpeg를 정식 Homebrew가 아닌 외부 탭으로 설치해둔 경우입니다. 그 ffmpeg는 그대로 두고 whisper만 따로 설치하세요.

```bash
brew install pipx
pipx install --backend pip openai-whisper
```

이렇게 하면 whisper가 기존 ffmpeg를 그대로 씁니다. `whisper --help`가 응답하면 끝입니다.

**한국어 영상인데 받아쓰기 정확도가 낮아요**
기본 모델(base)은 빠른 대신 한국어가 약합니다. Claude에게 "small 모델로 다시 뽑아줘" 또는 "medium 모델로"라고 하세요. 느려지는 만큼 정확해집니다.

**`/대본추출`을 쳐도 반응이 없어요**
스킬 폴더 위치를 확인하세요. `~/.claude/skills/대본추출/SKILL.md` 파일이 있어야 합니다. Claude Code를 완전히 종료했다가 다시 열어야 새 스킬을 읽습니다.

---

## 업데이트

스킬이 고쳐지면 폴더에서 한 줄:

```bash
cd ~/.claude/skills/대본추출 && git pull
```

Mac 한 줄 설치 스크립트를 다시 돌려도 됩니다. 이미 설치된 건 건너뛰고 스킬만 갱신합니다.

---

## 폴더 구조

```
대본추출/
├── SKILL.md      ← 스킬 본체. Claude Code가 읽는 파일
├── README.md     ← 이 문서
├── install.sh    ← Mac 한 줄 설치 스크립트
└── LICENSE
```

---

## 라이선스

MIT. 자유롭게 쓰고 고치고 나누셔도 됩니다.
