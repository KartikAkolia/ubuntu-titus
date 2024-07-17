#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script. Please run: sudo ./install.sh" 2>&1
  exit 1
fi

# Variables
username=$(id -u -n 1000)
builddir=$(pwd)
config_dir="/home/$username/.config"
fonts_dir="/home/$username/.fonts"
pictures_dir="/home/$username/Pictures"
sddm_themes_dir="/usr/share/sddm/themes"

# Update package list and upgrade system
apt update && apt upgrade -y

# Install nala
apt install nala -y

# Create necessary directories
mkdir -p "$config_dir" "$fonts_dir" "$pictures_dir" "$sddm_themes_dir"

# Copy config files and background
cp .Xresources "/home/$username"
cp .Xnord "/home/$username"
cp -R dotconfig/* "$config_dir/"
cp bg.jpg "$pictures_dir/"
chown -R "$username:$username" "/home/$username"

# Install dependencies and essential programs
nala install libqt5svg5 qml-module-qtquick-controls qml-module-qtquick-controls2 -y
nala install feh bspwm sxhkd kitty rofi polybar picom thunar nitrogen lxpolkit x11-xserver-utils unzip yad wget pulseaudio pavucontrol -y

# Install other less important programs
nala install neofetch flameshot psmisc mangohud vim lxappearance papirus-icon-theme lxappearance fonts-noto-color-emoji sddm variety -y

# Download and install Nordic Theme
cd /usr/share/themes/ || exit
git clone https://github.com/EliverLara/Nordic.git

# Install fonts
cd "$builddir" || exit
nala install fonts-font-awesome -y
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip
unzip FiraCode.zip -d "$fonts_dir"
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Meslo.zip
unzip Meslo.zip -d "$fonts_dir"
mv dotfonts/fontawesome/otfs/*.otf "$fonts_dir/"
chown "$username:$username" "$fonts_dir"/*

# Reload fonts and remove zip files
fc-cache -vf
rm ./FiraCode.zip ./Meslo.zip

# Install Nordzy cursor
git clone https://github.com/alvatip/Nordzy-cursors
cd Nordzy-cursors || exit
./install.sh
cd "$builddir" || exit
rm -rf Nordzy-cursors

# Install Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
nala install ./google-chrome-stable_current_amd64.deb -y
rm google-chrome-stable_current_amd64.deb

# Enable graphical login and set default target to graphical
tar -xzvf slice.tar.gz -C /usr/share/sddm/themes
cp -f "$builddir/sddm.conf" /etc/
systemctl enable sddm
systemctl set-default graphical.target

# Cleanup
nala autoremove -y
nala clean

echo "Installation completed successfully."
