#!/bin/bash

echo "Lancement de l'installation Emir-Prime sur Arch Linux..."

# 1. Droits administrateur pour l'utilisateur
echo "Configuration des privilèges sudo..."
usermod -aG wheel emiralkan

# 2. Configuration des boutons spéciaux et drivers HP 15
echo "Installation des drivers et outils pour PC portable HP..."
sudo pacman -S --noconfirm xf86-input-libinput power-profiles-daemon brightnessctl NetworkManager-openvpn
sudo pacman -S firefox
sudo systemctl enable --now power-profiles-daemon

# 3. Configuration de l'interface KDE Plasma (Plasma 6)
echo "Optimisation de l'interface KDE..."
if command -v kwriteconfig6 &> /dev/null; then
    kwriteconfig6 --file kaccessrc --group Keyboard --key OnScreenDisplay true
    kwriteconfig6 --file kwinrc --group Plugins --key zoomEnabled false
else
    kwriteconfig5 --file kaccessrc --group Keyboard --key OnScreenDisplay true
    kwriteconfig5 --file kwinrc --group Plugins --key zoomEnabled false
fi

# 4. Activation du dépôt multilib (32-bit pour Wine)
echo "Activation du support 32-bit (multilib)..."
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf
fi
# pacman -Syu remplace apt update && apt upgrade
sudo pacman -Syu --noconfirm

# 5. Installation de Wine
echo "Installation de Wine (Compatibilité Windows)..."
sudo pacman -S --noconfirm wine wine-mono wine-gecko

# 6. Installation des outils de dev et système
echo "Installation des outils système et de dev..."
sudo pacman -S --noconfirm base-devel nasm python python-pip qemu-desktop wget

# 7. Installation et Configuration Apache2
echo "Installation et configuration Apache..."
sudo pacman -S --noconfirm apache
sudo systemctl enable --now httpd

# 8. Installation MariaDB (SQL)
echo "Installation MariaDB..."
sudo pacman -S --noconfirm mariadb
if [ ! -d "/var/lib/mysql/mysql" ]; then
    sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
fi
sudo systemctl enable --now mariadb

# 9. Installation de Flatpak
sudo pacman -S --noconfirm flatpak discover
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo "Configuration HP 15 et alias terminée !"
echo "Fais un 'sudo reboot' pour tout appliquer."
