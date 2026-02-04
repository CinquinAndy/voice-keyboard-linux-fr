# Project XDR: The Fedora Voice-to-AI Bridge 🎤🤖

Project XDR is a collaborative experimentation born from the need for a seamless, low-latency voice interface on Fedora Linux. Its mission is simple: **Talk naturally to your AI and your computer, and let it write for you without barriers.**

This tool transforms your voice into high-accuracy text that "types" directly into any application—whether you're prompting an LLM, writing code, or emailing—making AI interaction feel as fluid as a conversation.

## 🌟 The Vision: Silence the Keyboard

Built specifically for the Fedora ecosystem, Project XDR solves the common "input friction" by:
- **Direct Speech-to-AI**: Talk directly to your AI interfaces without the need for manual typing.
- **System-Wide Integration**: Works in any terminal, editor, or browser.
- **Distraction-Free Productivity**: Stay in the flow by using voice for long-form thoughts or complex commands.

## ✨ Key Technical Pillars

- **Deepgram Nova-2 Engine**: Optimized for the latest STT models with multi-language support (English/French).
- **Virtual Driver Architecture**: Uses `uinput` to act as a native hardware device—zero software compatibility issues.
- **Zero-Sudo Autopilot**: A robust `systemd` user service that handles audio and STT in the background automatically.
- **Smart Control**: A dedicated toggle script with visual notifications (`Ctrl+Alt+V`) to pause or resume listening instantly.

## 🚀 Quick Setup (Fedora)

### 1. Enable Hardware Access
Run once to allow your user to operate the virtual keyboard:
```bash
sudo cp 99-uinput.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules && sudo udevadm trigger
sudo usermod -aG input $USER
```
*Note: Log out and back in for the group changes to take effect.*

### 2. Launch the Vision
The service is ready to run in the background:
```bash
systemctl --user daemon-reload
systemctl --user enable --now voice-keyboard
```

## ⌨️ Productivity Shortcuts

Map `Ctrl + Alt + V` to the following command to toggle the "AI Listening" mode:
```bash
/home/andycinquin/.local/bin/toggle-voice-keyboard
```

## 📊 Monitoring (XDR Logs)
Watch the AI process your speech in real-time:
```bash
journalctl --user -u voice-keyboard -f
```

---
*Developed as a personal test laboratory to push the boundaries of human-AI interaction on the Linux desktop.*
