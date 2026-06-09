#!/bin/bash

# Script Emir-Prime version Arch Linux
USER_ACTUEL=$(whoami)
set -e

echo "Attente de 1 seconde avant de commencer..."
sleep 1

echo "Lancement de l'installation Emir-Prime (Arch Edition)..."
echo "Utilisateur détecté : $USER_ACTUEL"

demander_confirmation() {
    read -p "Voulez-vous installer / configurer : $1 ? [y/N] : " choix
    case "$choix" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

# =====================================================================
# 0. CHOIX DU BUREAU (DE)
# =====================================================================
installer_de() {
    echo "Choisis ton environnement de bureau :"
    echo "1) GNOME (Moderne/Stable)"
    echo "2) KDE Plasma (Personnalisable)"
    echo "3) XFCE (Léger)"
    echo "4) Hyprland (Wayland/Tiling)"
    read -p "Ton choix [1-4] : " de_choix

    case $de_choix in
        1) sudo pacman -S --noconfirm gnome gdm ;;
           sudo systemctl enable gdm ;;
        2) sudo pacman -S --noconfirm plasma-meta sddm ;;
           sudo systemctl enable sddm ;;
        3) sudo pacman -S --noconfirm xfce4 xfce4-goodies lightdm lightdm-gtk-greeter ;;
           sudo systemctl enable lightdm ;;
        4) sudo pacman -S --noconfirm hyprland xdg-desktop-portal-hyprland qt5-wayland qt6-wayland ;;
        *) echo "Choix invalide, installation ignorée." ;;
    esac
}

if demander_confirmation "Un environnement de bureau (DE)"; then
    installer_de
fi

# =====================================================================
# 1. METTRE A JOUR
# =====================================================================
if demander_confirmation "Mise à jour du système"; then
    sudo pacman -Syu --noconfirm
fi

# =====================================================================
# 2. Installer FastFetch
# =====================================================================
if demander_confirmation "L'installation de Fastfetch"; then
    sudo pacman -S --noconfirm fastfetch
fi

# =====================================================================
# 2.5. Outils pour la compilation Linux
# =====================================================================
if demander_confirmation "L'installation des outils de compilation kernel"; then
    sudo pacman -S --noconfirm base-devel linux-headers bison flex bc qemu-full virt-manager virt-viewer dnsmasq vde2 openbsd-netcat libguestfs
fi

# =====================================================================
# 3. WINE
# =====================================================================
if demander_confirmation "Installation de Wine (32-bit & 64-bit)"; then
    echo "Note : Assure-toi que [multilib] est activé dans /etc/pacman.conf"
    sudo pacman -S --noconfirm wine wine-mono wine-gecko winetricks
fi

# =====================================================================
# 4. OUTILS DE DEV & WEB
# =====================================================================
if demander_confirmation "Outils de Dev, Apache et MariaDB"; then
    sudo pacman -S --noconfirm nasm python python-pip clang gimp debootstrap gnupg gcc apache mariadb
    sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
    sudo systemctl enable --now mariadb
    sudo systemctl enable --now httpd
fi

# =====================================================================
# 5. CONFIGURATION FLATPAK
# =====================================================================
if demander_confirmation "Le gestionnaire Flatpak"; then
    sudo pacman -S --noconfirm flatpak
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    APPS=("org.vinegarhq.Sober" "org.vinegarhq.Vinegar" "com.valvesoftware.Steam" "com.discordapp.Discord" "com.jpexs.decompiler.flash" "org.videolan.VLC" "com.mattjakeman.ExtensionManager")

    for app in "${APPS[@]}"; do
        if demander_confirmation "Installer $app ?"; then
            flatpak install -y flathub "$app"
        fi
    done
fi

# =====================================================================
# 6. NETTOYAGE et REDEMARRAGE FINAL
# =====================================================================
echo "Nettoyage des paquets orphelins..."
sudo pacman -Rns $(pacman -Qdtq) || echo "Rien à nettoyer."

echo "Installation terminée !"
if demander_confirmation "Veux-tu redémarrer maintenant ?"; then
    sudo reboot
else
    echo "Redémarrage annulé."
fi
