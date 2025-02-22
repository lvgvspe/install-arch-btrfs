#!/bin/bash

# Arch Linux Installation Script
# Based on: https://gist.github.com/mjkstra/96ce7a5689d753e7a6bdd92cdc169bae

# Check if the user is root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

# Set keyboard layout
echo "Setting keyboard layout to US."
loadkeys us

# Check internet connection
echo "Checking internet connection..."
ping -c 3 archlinux.org

if [ $? -ne 0 ]; then
    echo "No internet connection. Please connect to the internet and try again."
    exit 1
fi

# Update system clock
echo "Updating system clock..."
timedatectl set-ntp true

# Disk partitioning
echo "Listing available disks..."
lsblk

echo "Please enter the disk you want to partition (e.g., /dev/sda):"
read DISK

echo "Do you want to use GPT partitioning? (y/n)"
read GPT

if [[ $GPT == "y" ]]; then
    echo "Creating GPT partition table..."
    parted $DISK mklabel gpt
else
    echo "Creating MBR partition table..."
    parted $DISK mklabel msdos
fi

echo "Creating partitions..."
echo "1. Boot partition (512M)"
echo "2. Root partition (remaining space)"

parted $DISK mkpart primary fat32 1MiB 513MiB
parted $DISK set 1 boot on
parted $DISK mkpart primary 513MiB 100%

# Format partitions
echo "Formatting partitions..."
mkfs.fat -F32 ${DISK}1
mkfs.btrfs -f ${DISK}2

# Mount partitions
echo "Mounting partitions..."
mount ${DISK}2 /mnt
mkdir /mnt/boot
mount ${DISK}1 /mnt/boot

# Install base system
echo "Installing base system..."
pacstrap /mnt base linux linux-firmware btrfs-progs

# Generate fstab
echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into the installed system
echo "Chrooting into the installed system..."
arch-chroot /mnt <<EOF

# Set time zone
echo "Setting time zone to America/New_York..."
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc

# Set locale
echo "Setting locale to en_US.UTF-8..."
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Set keyboard layout
echo "Setting keyboard layout to US..."
echo "KEYMAP=us" > /etc/vconsole.conf

# Set hostname
echo "Please enter the hostname:"
read HOSTNAME
echo $HOSTNAME > /etc/hostname

# Set up network
echo "Setting up network..."
echo "127.0.0.1   localhost" >> /etc/hosts
echo "::1         localhost" >> /etc/hosts
echo "127.0.1.1   $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

# Set root password
echo "Setting root password..."
passwd

# Install bootloader (GRUB)
echo "Installing GRUB..."
pacman -S grub --noconfirm
grub-install --target=i386-pc $DISK
grub-mkconfig -o /boot/grub/grub.cfg

# Install additional packages (optional)
echo "Installing additional packages (optional)..."
pacman -S networkmanager sudo vim --noconfirm

# Enable NetworkManager
echo "Enabling NetworkManager..."
systemctl enable NetworkManager

# Create a new user
echo "Creating a new user..."
echo "Please enter the username:"
read USERNAME
useradd -m -G wheel -s /bin/bash $USERNAME
echo "Please set a password for the new user:"
passwd $USERNAME

# Configure sudo for the new user
echo "Configuring sudo for the new user..."
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

EOF

# Finish installation
echo "Installation complete!"
echo "Unmounting partitions..."
umount -R /mnt
echo "You can now reboot your system:"
echo "1. Type 'exit' to leave the chroot environment."
echo "2. Run 'reboot' to restart your system."
