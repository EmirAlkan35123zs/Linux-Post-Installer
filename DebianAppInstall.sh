#!/bin/bash

# Script Emir-Prime version Debian
USER_ACTUEL=$(whoami)
set -e

echo "Attente de 1 seconde avant de commencer..."
sleep 1

echo "Lancement de l'installation Emir-Prime (Debian Edition)..."
echo "Utilisateur détecté : $USER_ACTUEL"

demander_confirmation() {
    read -p "Voulez-vous installer / configurer : $1 ? [y/N] : " choix
    case "$choix" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

# =====================================================================
# 1. METTRE A JOUR
# =====================================================================
if demander_confirmation "Mise à jour du système"; then
     sudo apt update && sudo apt upgrade -y
fi

# =====================================================================
# 2. Installer FastFetch
# =====================================================================
if demander_confirmation "L'installation de FastFetch"; then
    sudo apt install -y fastfetch
fi

# =====================================================================
# 2.5. Installer Les Outils pour La compilation de linux
# =====================================================================
if demander_confirmation "L'installation des outils kernel linux"; then
     sudo apt-get install -y build-essential libncurses-dev bison flex libssl-dev libelf-dev bc initramfs-tools debian-archive-keyring grub-pc ovmf guestfish libguestfs-tools guestfs-tools linux-headers-generic net-tools
fi

# =====================================================================
# 3. WINE
# =====================================================================
if demander_confirmation "Installation de Wine (32-bit)"; then
    sudo dpkg --add-architecture i386
    sudo apt update
    sudo apt install -y wine wine32 wine64 libwine libwine:i386 fonts-wine
fi

# =====================================================================
# 4. OUTILS DE DEV & WEB
# =====================================================================
if demander_confirmation "Les outils de Dev, Serveur Web Apache et MariaDB"; then
    sudo apt install -y nasm build-essential python3 python3-pip qemu-system qemu-utils clang gimp debootstrap wget gpg gcc apache2 mariadb-server xorriso
    sudo a2enmod autoindex env mime negotiation setenvif filter deflate status reqtimeout
    sudo a2ensite 000-default
fi

# =====================================================================
# 4.5. DISCORD ET STEAM (via APT ou Installation directe)
# =====================================================================
if demander_confirmation "L'installation de Discord et Steam"; then
    
    # Pour Steam (il est bien dans le dépôt multiverse)
    sudo add-apt-repository multiverse -y
    sudo apt update
    sudo apt install -y steam
    
    # Pour Discord (téléchargement et installation du .deb)
    echo "Téléchargement de Discord..."
    wget -O discord.deb "https://discord.com/api/download?platform=linux&format=deb"
    sudo apt install -y ./discord.deb
    rm discord.deb
fi

# =====================================================================
# 5. CONFIGURATION FLATPAK
# =====================================================================
if demander_confirmation "Le gestionnaire Flatpak et le dépôt Flathub"; then
    # 1. Installation du paquet flatpak
    sudo apt install -y flatpak
    
    # 2. Ajout du dépôt Flathub (une seule fois suffit, en sudo)
    echo "Configuration du dépôt Flathub..."
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    # 3. Liste des applications
    APPS=("org.vinegarhq.Sober" "org.vinegarhq.Vinegar" "com.adobe.Flash-Player-Projector" "com.jpexs.decompiler.flash" "org.videolan.VLC" "com.mattjakeman.ExtensionManager")

    # 4. Boucle d'installation
    for app in "${APPS[@]}"; do
        if demander_confirmation "Installer $app ?"; then
            # Pas besoin de sudo pour installer des apps flatpak 
            # (sauf si tu veux les installer pour tout le système, mais le défaut utilisateur est mieux)
            flatpak install -y flathub "$app"
        fi
    done
fi

# =====================================================================
# 6. NETTOYAGE et REDEMARRAGE FINAL
# =====================================================================
echo "Mise à jour et Nettoyage..."
sudo apt autoremove -y

echo "Installation terminée !"
if demander_confirmation "Veux-tu redémarrer maintenant pour appliquer les changements ?"; then
    sudo reboot
else
    echo "Redémarrage annulé."
fi
