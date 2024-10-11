#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
  exit 1
fi

username=$(id -u -n 1000)
builddir=$(pwd)

# Update packages list and update system
apt update
apt upgrade -y


# Create directories
cd "$builddir" || exit
mkdir -p "/home/$username/.config"
mkdir -p "/home/$username/.fonts"
mkdir -p "/home/$username/Pictures"
mkdir -p /usr/share/sddm/themes
cp .Xresources "/home/$username"
cp .Xnord "/home/$username"
cp -R dotconfig/* "/home/$username/.config/"
cp bg.jpg "/home/$username/Pictures/"
chown -R "$username:$username" "/home/$username"

# Install sugar-candy dependencies
apt install libqt5svg5 qml-module-qtquick-controls qml-module-qtquick-controls2 -y
# Install Essential Programs
apt install feh bspwm sxhkd kitty rofi polybar picom thunar nitrogen lxpolkit x11-xserver-utils unzip yad wget pulseaudio pavucontrol -y
# Install Other less important Programs
apt install flameshot psmisc vim lxappearance papirus-icon-theme fonts-noto-color-emoji sddm variety -y

# Download Nordic Theme
cd /usr/share/themes/ || exit
git clone https://github.com/EliverLara/Nordic.git

# Install fonts
cd "$builddir" || exit
nala install fonts-font-awesome
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip
unzip FiraCode.zip -d "/home/$username/.fonts"
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Meslo.zip
unzip Meslo.zip -d "/home/$username/.fonts"
mv dotfonts/fontawesome/otfs/*.otf "/home/$username/.fonts/"
chown "$username:$username" "/home/$username/.fonts/*"

# Reload fonts
fc-cache -vf
# Remove zip files
rm ./FiraCode.zip ./Meslo.zip

# Install Nordzy cursor
git clone https://github.com/alvatip/Nordzy-cursors
cd Nordzy-cursors || exit
./install.sh
cd "$builddir" || exit
rm -rf Nordzy-cursors

# Install Google Chrome
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
sudo apt update
sudo apt install google-chrome-stable -y

# Enable graphical login and change target from CLI to GUI
tar -xzvf slice.tar.gz -C /usr/share/sddm/themes
cp -f "$builddir/sddm.conf" /etc/
systemctl enable sddm
systemctl set-default graphical.target
