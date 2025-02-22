sudo systemctl edit --full grub-btrfsd

# Enable grub-btrfsd service to run on boot
sudo systemctl enable grub-btrfsd

# Install yay
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

# Install "timeshift-autosnap", a configurable pacman hook which automatically makes snapshots before pacman upgrades.
yay -S timeshift-autosnap

yay -S plasma-desktop plasma-pa plasma-nm plasma-systemmonitor plasma-firewall plasma-browser-integration kscreen kwalletmanager kwallet-pam bluedevil powerdevil power-profiles-daemon kdeplasma-addons xdg-desktop-portal-kde xwaylandvideobridge kde-gtk-config breeze-gtk cups print-manager konsole dolphin ffmpegthumbs firefox kate okular gwenview ark pinta spectacle dragon

# Install SDDM
yay -S sddm

# Enable SDDM service to make it start on boot
sudo systemctl enable sddm

# If using KDE I suggest installing this to control the SDDM configuration from the KDE settings App
yay -S --needed sddm-kcm

# Now it's time to reboot the system
echo "Now it's time to reboot the system
