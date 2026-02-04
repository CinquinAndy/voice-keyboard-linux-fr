use std::env;
use std::process::Command;
use tracing::{debug, warn};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum KeyboardLayout {
    Qwerty,
    Azerty,
}

impl KeyboardLayout {
    /// Détecte le layout clavier actuel du système
    pub fn detect() -> Self {
        // Méthode 1: Vérifier la variable d'environnement
        if let Ok(xkb_layout) = env::var("XKB_DEFAULT_LAYOUT") {
            debug!("XKB_DEFAULT_LAYOUT: {}", xkb_layout);
            if xkb_layout.contains("fr") || xkb_layout.contains("azerty") {
                return Self::Azerty;
            }
        }
        
        // Méthode 2: Utiliser setxkbmap pour X11
        if let Ok(output) = Command::new("setxkbmap").arg("-query").output() {
            let output_str = String::from_utf8_lossy(&output.stdout);
            debug!("setxkbmap output: {}", output_str);
            for line in output_str.lines() {
                if line.starts_with("layout:") {
                    if line.contains("fr") {
                        return Self::Azerty;
                    }
                }
            }
        }
        
        // Méthode 3: Utiliser localectl pour systemd
        if let Ok(output) = Command::new("localectl").arg("status").output() {
            let output_str = String::from_utf8_lossy(&output.stdout);
            debug!("localectl output: {}", output_str);
            for line in output_str.lines() {
                if line.contains("X11 Layout:") && line.contains("fr") {
                    return Self::Azerty;
                }
            }
        }
        
        // Par défaut, assume QWERTY
        warn!("Could not detect keyboard layout, defaulting to QWERTY");
        Self::Qwerty
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_layout_detection() {
        // Just verify it doesn't panic
        let layout = KeyboardLayout::detect();
        println!("Detected layout: {:?}", layout);
    }
}
