#!/bin/bash

# Configuration
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
STATE_FILE="$RUNTIME_DIR/voice-keyboard.state"
LOCK_FILE="/tmp/voice-keyboard.lock"
SERVICE_NAME="voice-keyboard"

echo "🔄 Voice Keyboard: Toggle & Self-Heal"

# 1. Check if the binary is running (EXACT match to avoid wrapper/OSD)
PID=$(pgrep -x "voice-keyboard")

# SELF-HEAL FUNCTION
perform_reset() {
    echo "⚠️  Detected broken state or missing process. Performing full reset..."
    notify-send "Voice Keyboard" "Service error. Resetting..." -i dialog-warning -t 3000
    
    # Stop everything
    systemctl --user stop "$SERVICE_NAME" 2>/dev/null
    pkill -9 -f "voice-keyboard" 2>/dev/null
    
    # Clean stale files
    echo "🧹 Cleaning stale lock and state files..."
    rm -f "$LOCK_FILE"
    rm -f "$STATE_FILE"
    
    # Restart cleanly
    echo "🚀 Restarting service..."
    if systemctl --user start "$SERVICE_NAME"; then
        notify-send "Voice Keyboard" "Service restarted and active" -i microphone-sensitivity-medium-symbolic -t 2000
        echo "✅ Reset complete. Service is running."
    else
        notify-send "Voice Keyboard" "CRITICAL: Failed to restart service" -i dialog-error
        echo "❌ Reset failed."
        exit 1
    fi
}

# 2. Logic: If no PID, or if state file is missing/stale while PID exists
if [ -z "$PID" ]; then
    perform_reset
    exit 0
fi

# 3. Try to toggle the running process
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
        echo "🎤 State: ACTIVE"
        notify-send "Voice Keyboard" "Listening..." -i microphone-sensitivity-high-symbolic -t 2000
    elif [ "$STATE" == "PAUSED" ]; then
        echo "⏸️  State: PAUSED"
        notify-send "Voice Keyboard" "Paused" -i microphone-sensitivity-muted-symbolic -t 2000
    else
        echo "❓ State unknown or file missing. Attempting self-heal anyway."
        perform_reset
    fi
else
    echo "❌ Failed to send signal to PID $PID."
    perform_reset
fi
