#!/bin/bash

# Récupérer le nom de l'utilisateur qui lance le script
USER_ACTUEL=$(whoami)
set -e

# Exemple de confort (à mettre au début)
echo "⌛ Attente de 3 secondes avant de commencer..."
sleep 3

echo "🚀 Lancement de l'installation Emir-Prime..."
echo "👤 Utilisateur détecté : $USER_ACTUEL"

# Fonction pour poser les questions de manière propre
demander_confirmation() {
    read -p "❓ Voulez-vous installer / configurer : $1 ? [y/N] : " choix
    case "$choix" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

# =====================================================================
# 0. (1) METRE A JOUR
# =====================================================================
if demander_confirmation "Mise A Jours"; then
      sudo apt update && sudo apt upgrade -y
fi

# =====================================================================
# 1. PASSAGE EN ADMIN VIA LE COMPTE ROOT
# =====================================================================
if demander_confirmation "L'accès Admin (Sudoers) pour l'utilisateur $USER_ACTUEL"; then
    if groups | grep -qw sudo; then
        echo "✅ Tu as déjà les privilèges Admin."
    elif [ "$USER_ACTUEL" != "root" ]; then
        echo "🔒 Configuration des droits Sudo..."
        # On utilise sudo ici, en supposant que l'utilisateur a le mot de passe de son propre compte
        # C'est la méthode standard sous Debian/Ubuntu
        su -c "apt update && apt install -y sudo && usermod -aG sudo $USER_ACTUEL && echo '$USER_ACTUEL ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/$USER_ACTUEL-prime && chmod 0440 /etc/sudoers.d/$USER_ACTUEL-prime"
        echo "✅ Privilèges Admin configurés !"
    fi
fi

# =====================================================================
# 2. Installer NeoFetch
# =====================================================================
if demander_confirmation "L'installation de NeoFetch"; then
    sudo apt install -y neofetch
fi

# =====================================================================
# 2.5. Installer Les Outil pour La compilation de kernel linux
# =====================================================================
if demander_confirmation "L'installation de outil kernel linux"; then
      sudo apt-get install build-essential libncurses-dev bison flex libssl-dev libelf-dev bc initramfs-tools debian-archive-keyring grub-pc ovmf guestfish libguestfs-tools guestfs-tools linux-headers-generic net-tools -y
fi

# =====================================================================
# 3. MISE À JOUR & WINE
# =====================================================================
if demander_confirmation "La mise à jour système et le support Wine (32-bit)"; then
    sudo dpkg --add-architecture i386
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y wine wine32 wine64 libwine libwine:i386 fonts-wine
fi

# =====================================================================
# 4. OUTILS DE DEV & WEB
# =====================================================================
if demander_confirmation "Les outils de Dev, Serveur Web Apache et MariaDB SQL"; then
    sudo apt install -y nasm build-essential python3 python3-pip qemu-system qemu-utils clang gimp debootstrap wget gpg gcc apache2 mariadb-server geany -y
    sudo a2enmod autoindex env mime negotiation setenvif filter deflate status reqtimeout
    sudo a2ensite 000-default
fi

# =====================================================================
# 5. CONFIGURATION FLATPAK
# =====================================================================
if demander_confirmation "Le gestionnaire Flatpak et le dépôt Flathub"; then
    sudo apt install -y flatpak
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    APPS=("org.vinegarhq.Sober" "org.vinegarhq.Vinegar" "com.valvesoftware.Steam" "com.discordapp.Discord" "com.visualstudio.code" "com.adobe.Flash-Player-Projector" "com.jpexs.decompiler.flash" "org.videolan.VLC" "com.mattjakeman.ExtensionManager")

    for app in "${APPS[@]}"; do
        if demander_confirmation "Installer $app ?"; then
            flatpak install -y flathub "$app"
        fi
    done
fi

# =====================================================================
# 6. NETTOYAGE FINAL
# =====================================================================
echo "🧹🔄️ Mise a Jours et Nettoyage..."
sudo apt autoremove -y

echo "✅ Installation terminée !"
echo "🚀 N'oublie pas de faire : (sudo reboot) pour appliquer tous les changements !"
