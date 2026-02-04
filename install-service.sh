#!/bin/bash
# Installation rapide du service voice-keyboard

set -e

echo "🎤 Installation de Voice Keyboard comme service..."

# Variables
INSTALL_DIR="$HOME/.local/bin"
SERVICE_DIR="$HOME/.config/systemd/user"
PROJECT_DIR="/home/andycinquin/clonedrepo/voice-keyboard-linux-fr"

# 1. Compiler en release
echo "📦 Compilation en release..."
cd "$PROJECT_DIR"
cargo build --release

# 2. Créer les dossiers
echo "📁 Création des dossiers..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$SERVICE_DIR"

# 3. Copier le binaire
echo "📋 Copie du binaire..."
cp target/release/voice-keyboard "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/voice-keyboard"

# 4. Copier le script de toggle
echo "🔘 Installation du script toggle..."
cp toggle-voice-keyboard.sh "$INSTALL_DIR/toggle-voice-keyboard"
chmod +x "$INSTALL_DIR/toggle-voice-keyboard"

# 5. Créer le wrapper avec sudo
echo "🔧 Création du wrapper sudo..."
cat > "$INSTALL_DIR/voice-keyboard-wrapper" << 'EOF'
#!/bin/bash
# Wrapper pour lancer voice-keyboard avec sudo
export DEEPGRAM_API_KEY="${DEEPGRAM_API_KEY}"
export RUST_LOG="${RUST_LOG:-info}"
exec sudo -E $HOME/.local/bin/voice-keyboard --language multi --model nova-3-general
EOF
chmod +x "$INSTALL_DIR/voice-keyboard-wrapper"

# 6. Copier le service systemd
echo "⚙️  Installation du service systemd..."
sed "s|%DEEPGRAM_API_KEY%|${DEEPGRAM_API_KEY}|g" voice-keyboard.service > "$SERVICE_DIR/voice-keyboard.service"

# 7. Recharger systemd
echo "🔄 Rechargement systemd..."
systemctl --user daemon-reload

echo ""
echo "✅ Installation terminée!"
echo ""
echo "⚠️  IMPORTANT: Configuration requise"
echo ""
echo "1. Ajouter cette ligne à sudoers (sudo visudo):"
echo "   $(whoami) ALL=(ALL) NOPASSWD: $INSTALL_DIR/voice-keyboard"
echo ""
echo "2. Vérifier que DEEPGRAM_API_KEY est définie:"
echo "   export DEEPGRAM_API_KEY='votre_clé'"
echo ""
echo "3. Activer et démarrer le service:"
echo "   systemctl --user enable voice-keyboard"
echo "   systemctl --user start voice-keyboard"
echo ""
echo "4. Configurer le raccourci clavier:"
echo "   Commande: $INSTALL_DIR/toggle-voice-keyboard"
echo "   Touche: Ctrl+Alt+V (ou autre)"
echo ""
echo "📚 Voir le guide complet: service_installation_guide.md"
