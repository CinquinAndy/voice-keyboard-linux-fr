# Voice Keyboard (Linux/Fedora)

A low-latency voice-to-text tool written in Rust. It captures audio, sends it to Deepgram (Nova-2 model), and simulates keystrokes via `uinput`.

Designed for seamless interaction with LLMs or text editors on Linux without keeping focus on a specific window.

## Architecture

* **Language**: Rust (Tokio async runtime).
* **Audio**: Native ALSA capture.
* **Input**: Linux `uinput` virtual device (simulates a real hardware keyboard).
* **API**: Deepgram WebSockets (Stream).
* **Control**:
  * **Singleton**: Uses `/tmp/voice-keyboard.lock` to prevent duplicate instances.
  * **IPC**: Listens for `SIGUSR1` to toggle between `ACTIVE` and `PAUSED` states.
  * **State**: Writes status to `/tmp/voice-keyboard.state`.

## Installation

### 1. Build

```bash
cargo build --release
cp target/release/voice-keyboard ~/.local/bin/
```

### 2. Permissions (Zero-Sudo)

Allow the current user to write to `/dev/uinput` without root privileges:

```bash
# Add udev rule
echo 'KERNEL=="uinput", GROUP="input", MODE="0660"' | sudo tee /etc/udev/rules.d/99-uinput.rules

# Apply rules
sudo udevadm control --reload-rules && sudo udevadm trigger

# Add user to input group
sudo usermod -aG input $USER
```

*Logout and login required.*

### 3. Systemd Service

Enable the user service to run in the background.

```bash
systemctl --user daemon-reload
systemctl --user enable --now voice-keyboard
```

## Usage

### Toggle (Start/Stop Listening)

Send `SIGUSR1` to the process or use the provided script. This works instantly without killing the process.

```bash
~/.local/bin/toggle-voice-keyboard
```

*Recommendation: Bind this script to a global shortcut like `Ctrl+Alt+V`.*

### Logs

View real-time transcription status and errors:

```bash
journalctl --user -u voice-keyboard -f
```

## Configuration

Environment variables (set in systemd service or wrapper):

* `DEEPGRAM_API_KEY`: Your API key.
* `RUST_LOG`: Logging level (default: `info`).
* `XDG_RUNTIME_DIR` / `PULSE_SERVER`: Audio environment context.
