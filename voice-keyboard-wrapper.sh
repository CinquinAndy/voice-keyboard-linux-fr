#!/bin/bash
# Wrapper pour lancer voice-keyboard avec sudo et les bonnes variables

# Définir la clé Deepgram
export DEEPGRAM_API_KEY="511d5f13c70f1d21cd2a8be6b8ed49fc943c54c8"
export RUST_LOG="${RUST_LOG:-info}"

# Passer les variables audio nécessaires
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR}"
export PULSE_SERVER="${PULSE_SERVER:-unix:${XDG_RUNTIME_DIR}/pulse/native}"

# Lancer voice-keyboard
exec /home/andycinquin/.local/bin/voice-keyboard "$@"
