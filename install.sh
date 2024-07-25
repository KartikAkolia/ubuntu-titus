#!/bin/bash

# Function to check the last command status and exit if it failed
check_command_status() {
  if [[ $? -ne 0 ]]; then
    echo "Error: $1 failed. Exiting." >&2
    exit 1
  fi
}

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script. Please run: sudo ./install.sh" >&2
  exit 1
fi

# Variables
username=$(id -u -n 1000)
builddir=$(pwd)
config_dir="/home/$username/.config"
fonts_dir="/home/$username/.fonts"
pictures_dir="/home/$username/Pictures"
sddm_themes_dir="/usr/share/sddm/themes"
font_urls=(
  "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip"
  "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Meslo.zip"
)
chrome_deb="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
nordic_theme_repo="https://github.com/EliverLara/Nordic.git"
nordzy_cursors_repo="https://github.com/alvatip/Nordzy-cursors"

# Update package list and upgrade system
apt update && apt upgrade -y
check_command_status "System update and upgrade"

# Install nala
apt install nala -y
check_command_status "Installing nala"

# Create necessary directories
mkdir -p "$config_dir" "$fonts_dir" "$pictures_dir" "$sddm_themes_dir"
check_command_status "Creating directories"

# Copy config files and background
cp .Xresources "/home/$username" && cp .Xnord "/home/$username"
cp -R dotconfig/* "$config_dir/"
cp bg.jpg "$pictures_dir/"
chown -R "$username:$username" "/home/$username"
check_command_status "Copying configuration files and background"

# Install dependencies and essential programs
nala install libqt5svg5 qml-module-qtquick-controls qml-module-qtquick-controls2 \
feh bspwm sxhkd kitty rofi polybar picom thunar nitrogen lxpolkit x11-xserver-utils \
unzip yad wget pulseaudio pavucontrol -y
check_command_status "Installing dependencies and essential programs"

# Install other less important programs
nala install neofetch flameshot psmisc mangohud vim lxappearance papirus-icon-theme \
lxappearance fonts-noto-color-emoji sddm variety -y
check_command_status "Installing additional programs"

# Download and install Nordic Theme
git clone "$nordic_theme_repo" /usr/share/themes/Nordic
check_command_status "Cloning Nordic theme"

# Install fonts
for url in "${font_urls[@]}"; do
  filename=$(basename "$url")
  wget "$url"
  check_command_status "Downloading font from $url"
  unzip "$filename" -d "$fonts_dir"
  check_command_status "Unzipping $filename"
  rm "$filename"
done

# Move additional font files
mv dotfonts/fontawesome/otfs/*.otf "$fonts_dir/"
chown "$username:$username" "$fonts_dir"/*
fc-cache -vf
check_command_status "Installing fonts"

# Install Nordzy cursor
git clone "$nordzy_cursors_repo"
cd Nordzy-cursors || exit 1
./install.sh
cd "$builddir" || exit 1
rm -rf Nordzy-cursors
check_command_status "Installing Nordzy cursor"

# Install Google Chrome
wget "$chrome_deb"
check_command_status "Downloading Google Chrome"
nala install ./google-chrome-stable_current_amd64.deb -y
check_command_status "Installing Google Chrome"
rm google-chrome-stable_current_amd64.deb

# Enable graphical login and set default target to graphical
tar -xzvf slice.tar.gz -C /usr/share/sddm/themes
cp -f "$builddir/sddm.conf" /etc/
systemctl enable sddm
systemctl set-default graphical.target
check_command_status "Configuring graphical login"

# Cleanup
nala autoremove -y
nala clean
check_command_status "Cleanup"

echo "Installation completed successfully."
