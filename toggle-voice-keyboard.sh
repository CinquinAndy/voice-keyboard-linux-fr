#!/bin/bash
# Script pour toggle (activer/désactiver) le voice keyboard

# Trouver le PID du processus voice-keyboard
PID=$(pgrep -f "voice-keyboard" | head -n 1)

if [ -z "$PID" ]; then
    echo "❌ Voice keyboard is not running"
    notify-send "Voice Keyboard" "Service not running" -i dialog-error
    exit 1
fi

# Envoyer le signal SIGUSR1 pour toggle
kill -SIGUSR1 "$PID"

# Vérifier si le signal a été envoyé
if [ $? -eq 0 ]; then
    echo "✅ Toggle signal sent to PID $PID"
    notify-send "Voice Keyboard" "Toggled listening state" -i microphone-sensitivity-high
else
    echo "❌ Failed to send toggle signal"
    notify-send "Voice Keyboard" "Failed to toggle" -i dialog-error
    exit 1
fi
