# Voice Keyboard Linux - Édition Française 🇫🇷

Clavier vocal multilingue pour Linux avec support **français/anglais** et détection automatique du layout **AZERTY/QWERTY**.

Basé sur [voice-keyboard-linux](https://github.com/deepgram/voice-keyboard-linux) avec ajout du support multilingue et AZERTY.

## ✨ Caractéristiques

- 🌍 **Multilingue** : Français et Anglais (détection automatique)
- ⌨️ **AZERTY/QWERTY** : Détection automatique du layout clavier
- 🎯 **Caractères accentués** : Support complet (é, è, à, ù, ç)
- 🎤 **Deepgram Nova-3** : Reconnaissance vocale de haute qualité
- 🔄 **Service systemd** : Démarre automatiquement avec le système
- ⌨️ **Toggle par raccourci** : Activer/désactiver avec un raccourci clavier

---

## 📋 Prérequis (Fedora)

```bash
# Installer les dépendances de build
sudo dnf install -y rust cargo alsa-lib-devel systemd-devel

# Vérifier que vous avez accès à /dev/uinput
ls -l /dev/uinput
```

---

## 🚀 Installation Complète (Fedora)

### Étape 1 : Cloner et Compiler

```bash
# Cloner le repository
git clone https://github.com/CinquinAndy/voice-keyboard-linux-fr.git
cd voice-keyboard-linux-fr

# Compiler en mode release
cargo build --release
```

### Étape 2 : Installer le Binaire

```bash
# Créer le dossier d'installation
mkdir -p ~/.local/bin

# Copier le binaire
cp target/release/voice-keyboard ~/.local/bin/

# Ajouter ~/.local/bin au PATH (si pas déjà fait)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Étape 3 : Configurer la Clé Deepgram

```bash
# Pour Fish shell
set -Ux DEEPGRAM_API_KEY "votre-clé-deepgram-ici"

# Pour Bash/Zsh
echo 'export DEEPGRAM_API_KEY="votre-clé-deepgram-ici"' >> ~/.bashrc
source ~/.bashrc
```

> 💡 Obtenez une clé gratuite sur [deepgram.com](https://console.deepgram.com/signup)

### Étape 4 : Créer le Wrapper avec Sudo

```bash
# Créer le wrapper
cat > ~/.local/bin/voice-keyboard-wrapper << 'EOF'
#!/bin/bash
# Wrapper pour lancer voice-keyboard avec sudo

# Définir la clé Deepgram
export DEEPGRAM_API_KEY="VOTRE_CLÉ_ICI"
export RUST_LOG="${RUST_LOG:-info}"

# Passer les variables audio nécessaires
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR}"
export PULSE_SERVER="${PULSE_SERVER:-unix:${XDG_RUNTIME_DIR}/pulse/native}"

# Lancer voice-keyboard avec sudo
exec sudo \
  XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
  PULSE_SERVER="$PULSE_SERVER" \
  DEEPGRAM_API_KEY="$DEEPGRAM_API_KEY" \
  RUST_LOG="$RUST_LOG" \
  /home/$USER/.local/bin/voice-keyboard --language multi --model nova-3-general "$@"
EOF

# Remplacer VOTRE_CLÉ_ICI par votre vraie clé
sed -i "s/VOTRE_CLÉ_ICI/$DEEPGRAM_API_KEY/" ~/.local/bin/voice-keyboard-wrapper

# Rendre exécutable
chmod +x ~/.local/bin/voice-keyboard-wrapper
```

### Étape 5 : Configurer Sudoers

```bash
# Éditer sudoers
sudo visudo
```

**Ajouter ces lignes à la fin du fichier :**

```
Defaults:VOTRE_USERNAME env_keep += "DEEPGRAM_API_KEY RUST_LOG XDG_RUNTIME_DIR PULSE_SERVER"
VOTRE_USERNAME ALL=(ALL) NOPASSWD: /home/VOTRE_USERNAME/.local/bin/voice-keyboard
```

> ⚠️ Remplacez `VOTRE_USERNAME` par votre nom d'utilisateur (`whoami`)

### Étape 6 : Installer le Service Systemd

```bash
# Créer le dossier systemd user
mkdir -p ~/.config/systemd/user

# Copier le service
cp voice-keyboard.service ~/.config/systemd/user/

# Recharger systemd
systemctl --user daemon-reload

# Activer le service (démarrage auto)
systemctl --user enable voice-keyboard

# Démarrer le service maintenant
systemctl --user start voice-keyboard

# Vérifier le statut
systemctl --user status voice-keyboard
```

**Vous devriez voir** : `Active: active (running)` ✅

### Étape 7 : Installer le Script Toggle

```bash
# Copier le script
cp toggle-voice-keyboard.sh ~/.local/bin/toggle-voice-keyboard
chmod +x ~/.local/bin/toggle-voice-keyboard
```

### Étape 8 : Configurer le Raccourci Clavier (GNOME)

1. Ouvrir **Paramètres** → **Clavier** → **Raccourcis clavier**
2. Défiler vers **Raccourcis personnalisés** → **Ajouter un raccourci**
3. Remplir :
   - **Nom** : `Voice Keyboard Toggle`
   - **Commande** : `/home/VOTRE_USERNAME/.local/bin/toggle-voice-keyboard`
   - **Raccourci** : Appuyer sur `Ctrl+Alt+V`

---

## 🎯 Utilisation

### Activer/Désactiver l'Écoute

1. **Appuyez sur `Ctrl+Alt+V`** (votre raccourci configuré)
2. Une notification apparaît :
   - "🎤 Voice keyboard: ACTIVE" → Écoute activée
   - "🎤 Voice keyboard: PAUSED" → Écoute en pause

### Dictée Vocale

Quand l'écoute est **ACTIVE** :

1. Placez votre curseur où vous voulez écrire
2. **Parlez clairement** dans votre micro
3. Le texte apparaît automatiquement !

**Exemples** :
```
"Bonjour, ceci est un test de dictée vocale"
→ Bonjour, ceci est un test de dictée vocale

"Hello, this is a voice typing test"
→ Hello, this is a voice typing test
```

### Caractères Spéciaux

Le système détecte automatiquement **AZERTY** et tape correctement :

- Accents : `é`, `è`, `à`, `ù`, `ç`
- Majuscules : `É`, `È`, `À`, `Ç`
- Ponctuation française automatique

**Commandes vocales** :
- "point" → `.`
- "virgule" → `,`
- "point d'interrogation" → `?`
- "point d'exclamation" → `!`
- "nouvelle ligne" → Entrée
- "deux points" → `:`

---

## 🔧 Commandes Utiles

### Gérer le Service

```bash
# Voir le statut
systemctl --user status voice-keyboard

# Arrêter
systemctl --user stop voice-keyboard

# Redémarrer
systemctl --user restart voice-keyboard

# Désactiver (ne démarre plus au boot)
systemctl --user disable voice-keyboard

# Voir les logs en direct
journalctl --user -u voice-keyboard -f
```

### Tester Manuellement

```bash
# Test audio (vérifier le micro)
~/.local/bin/voice-keyboard-wrapper --test-audio

# Test STT (connexion Deepgram)
~/.local/bin/voice-keyboard-wrapper --test-stt

# Mode debug (voir les transcriptions sans taper)
~/.local/bin/voice-keyboard-wrapper --debug-stt
```

---

## 🐛 Dépannage

### Le service ne démarre pas

```bash
# Voir l'erreur exacte
journalctl --user -u voice-keyboard -n 50 --no-pager

# Vérifier les permissions
ls -l ~/.local/bin/voice-keyboard
ls -l /dev/uinput
```

### Erreur "Permission denied" sur /dev/uinput

```bash
# Ajouter l'utilisateur au groupe input
sudo usermod -a -G input $USER

# Se déconnecter et reconnecter pour appliquer
```

### Erreur audio "Host is down"

Le wrapper n'a pas accès à PulseAudio/PipeWire. Vérifiez :

```bash
# Variables d'environnement audio
echo $XDG_RUNTIME_DIR
echo $PULSE_SERVER

# Tester l'audio
pactl info
```

### Le toggle ne fonctionne pas

```bash
# Vérifier que le service tourne
ps aux | grep voice-keyboard

# Envoyer le signal manuellement
kill -SIGUSR1 $(pgrep -f voice-keyboard)
```

### La clé Deepgram n'est pas reconnue

```bash
# Vérifier la variable
echo $DEEPGRAM_API_KEY

# Vérifier dans le wrapper
cat ~/.local/bin/voice-keyboard-wrapper | grep DEEPGRAM_API_KEY
```

---

## ⚙️ Configuration Avancée

### Changer de Modèle/Langue

Éditez `~/.local/bin/voice-keyboard-wrapper` :

```bash
# Français uniquement
--language fr --model nova-3-general

# Anglais uniquement (plus rapide avec Flux)
--language en --model flux-general-en

# Multilingue (défaut)
--language multi --model nova-3-general
```

Puis redémarrez :

```bash
systemctl --user restart voice-keyboard
```

### Modèles Deepgram Disponibles

- **`nova-3-general`** : Multilingue, haute précision (recommandé)
- **`flux-general-en`** : Anglais uniquement, ultra-rapide
- **`nova-2-general`** : Version précédente, moins précis

### Options CLI

```bash
voice-keyboard --help

Options:
  --test-audio          Test audio input
  --test-stt            Test speech-to-text
  --debug-stt           Debug mode (print without typing)
  --stt-url <URL>       Custom STT service URL
  --voice-enter         Interpret "enter" as Enter key
  --uppercase           Convert to uppercase
  --model <MODEL>       Deepgram model [default: nova-3-general]
  --language <LANG>     Language code [default: multi]
```

---

## 📦 Désinstallation

```bash
# Arrêter et désactiver le service
systemctl --user stop voice-keyboard
systemctl --user disable voice-keyboard

# Supprimer les fichiers
rm ~/.config/systemd/user/voice-keyboard.service
rm ~/.local/bin/voice-keyboard
rm ~/.local/bin/voice-keyboard-wrapper
rm ~/.local/bin/toggle-voice-keyboard

# Recharger systemd
systemctl --user daemon-reload

# Supprimer la ligne dans sudoers
sudo visudo
# (supprimer les lignes ajoutées)
```

---

## 🤝 Contribution

Améliorations bienvenues ! N'hésitez pas à :

- 🐛 Reporter des bugs
- 💡 Proposer des fonctionnalités
- 🔧 Soumettre des Pull Requests

---

## 📝 Licence

Voir [LICENSE.txt](LICENSE.txt)

---

## 🙏 Crédits

- Projet original : [Deepgram Voice Keyboard](https://github.com/deepgram/voice-keyboard-linux)
- Support multilingue et AZERTY : [@CinquinAndy](https://github.com/CinquinAndy)
- STT : [Deepgram](https://deepgram.com)

---

## 📞 Support

- 🐛 Issues : [GitHub Issues](https://github.com/CinquinAndy/voice-keyboard-linux-fr/issues)
- 💬 Discussions : [GitHub Discussions](https://github.com/CinquinAndy/voice-keyboard-linux-fr/discussions)

---

**Profitez de la dictée vocale en français ! 🎉**
