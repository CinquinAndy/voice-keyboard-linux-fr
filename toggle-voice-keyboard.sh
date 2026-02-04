#!/bin/bash
# Improved Voice Keyboard Toggle Script

LOCK_FILE="/tmp/voice-keyboard.lock"

# Check if the process is actually running
if [ ! -f "$LOCK_FILE" ]; then
    echo "🚀 Voice keyboard is not running. Starting service..."
    systemctl --user start voice-keyboard
    notify-send "Voice Keyboard" "Service started" -i microphone-sensitivity-high-symbolic
    exit 0
fi

PID=$(cat "$LOCK_FILE")

# Verify the process still exists and is correct
if ! ps -p "$PID" > /dev/null; then
    echo "⚠️ Process $PID from lock file not found. Restarting..."
    rm "$LOCK_FILE"
    systemctl --user restart voice-keyboard
    notify-send "Voice Keyboard" "Service restarted" -i microphone-sensitivity-high-symbolic
    exit 0
fi

# State file location (prefer XDG_RUNTIME_DIR)
STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/voice-keyboard.state"

# Send SIGUSR1 to toggle the state
echo "📡 Sending toggle signal to PID $PID..."
if kill -SIGUSR1 "$PID" 2>/dev/null; then
    echo "✅ Toggle signal sent"
    
    # Wait a moment for the binary to write the new state
    sleep 0.2
    STATE="unknown"
    if [ -f "$STATE_FILE" ]; then
        STATE=$(cat "$STATE_FILE")
    fi

    if [ "$STATE" == "ACTIVE" ]; then
        notify-send "Voice Keyboard" "🎤 ÉCOUTE ACTIVE" -i microphone-sensitivity-high-symbolic -t 2000
    elif [ "$STATE" == "PAUSED" ]; then
        notify-send "Voice Keyboard" "🔇 EN PAUSE" -i microphone-sensitivity-muted-symbolic -t 2000
    else
        notify-send "Voice Keyboard" "Toggled State" -i microphone-sensitivity-medium-symbolic -t 2000
    fi
else
    echo "❌ Failed to send toggle signal"
    notify-send "Voice Keyboard" "Failed to toggle service" -i dialog-error
    exit 1
fi
