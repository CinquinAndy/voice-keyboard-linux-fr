#!/bin/bash
# Wrapper pour lancer voice-keyboard et l'OSD sans sudo

# Définir la clé Deepgram
export DEEPGRAM_API_KEY="511d5f13c70f1d21cd2a8be6b8ed49fc943c54c8"
export RUST_LOG="${RUST_LOG:-info}"

# Passer les variables audio nécessaires
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR}"
export PULSE_SERVER="${PULSE_SERVER:-unix:${XDG_RUNTIME_DIR}/pulse/native}"

# Lancer l'indicateur visuel (OSD) en arrière-plan
python3 /home/andycinquin/.local/bin/voice-keyboard-osd.py &
OSD_PID=$!

# Fonction de nettoyage
cleanup() {
    echo "Stopping OSD (PID $OSD_PID)..."
    kill $OSD_PID 2>/dev/null
    # On sort avec l'exit code du dernier programme capturé si disponible
    exit ${EXIT_CODE:-0}
}

# Trap pour s'assurer du nettoyage, mais ignorer SIGUSR1 (utilisé par le binaire)
trap cleanup SIGINT SIGTERM EXIT

# Lancer voice-keyboard
/home/andycinquin/.local/bin/voice-keyboard "$@"
EXIT_CODE=$? # Capturer l'exit code du binaire

# On force l'exécution du cleanup après que le binaire a fini
cleanup
