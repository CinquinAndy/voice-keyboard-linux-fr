#!/bin/bash
# Wrapper pour lancer voice-keyboard et l'OSD sans sudo

# Définir la clé Deepgram
export DEEPGRAM_API_KEY="511d5f13c70f1d21cd2a8be6b8ed49fc943c54c8"
export RUST_LOG="${RUST_LOG:-info}"

# Passer les variables audio nécessaires
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR}"
export PULSE_SERVER="${PULSE_SERVER:-unix:${XDG_RUNTIME_DIR}/pulse/native}"

# Lancer l'indicateur visuel (OSD) en arrière-plan
# Il restera actif tant que le service tourne
python3 /home/andycinquin/.local/bin/voice-keyboard-osd.py &
OSD_PID=$!

# Fonction de nettoyage lors de la sortie
cleanup() {
    echo "Stopping OSD (PID $OSD_PID)..."
    kill $OSD_PID 2>/dev/null
    exit 0
}

# Piéger les signaux pour s'assurer que l'OSD s'arrête proprement
# Sauf SIGUSR1 qui est pour le toggle !
trap cleanup SIGINT SIGTERM EXIT

# Lancer voice-keyboard
# Note: On ne fait PAS 'exec' ici pour pouvoir faire le trap cleanup après
/home/andycinquin/.local/bin/voice-keyboard "$@"
