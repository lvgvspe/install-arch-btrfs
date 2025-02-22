#!/bin/bash

# Script de Instalação do Arch Linux
# Baseado em: https://gist.github.com/mjkstra/96ce7a5689d753e7a6bdd92cdc169bae

# Verificar se o usuário é root
if [[ $EUID -ne 0 ]]; then
   echo "Este script deve ser executado como root."
   exit 1
fi

# Configurar o layout do teclado
echo "Configurando o layout do teclado para US."
loadkeys br-abnt

# Verificar conexão com a internet
echo "Verificando conexão com a internet..."
ping -c 3 archlinux.org

if [ $? -ne 0 ]; then
    echo "Sem conexão com a internet. Por favor, conecte-se à internet e tente novamente."
    exit 1
fi

# Atualizar o relógio do sistema
echo "Atualizando o relógio do sistema..."
timedatectl set-ntp true

# Particionamento do disco
echo "Listando discos disponíveis..."
lsblk

echo "Por favor, insira o disco que deseja particionar (ex: /dev/sda):"
read DISK

echo "Deseja usar particionamento GPT? (s/n)"
read GPT

if [[ $GPT == "s" ]]; then
    echo "Criando tabela de partição GPT..."
    parted $DISK mklabel gpt
else
    echo "Criando tabela de partição MBR..."
    parted $DISK mklabel msdos
fi

echo "Criando partições..."
echo "1. Partição de boot (512M)"
echo "2. Partição raiz (restante do espaço)"

parted $DISK mkpart primary fat32 1MiB 513MiB
parted $DISK set 1 boot on
parted $DISK mkpart primary 513MiB 100%

# Formatar partições
echo "Formatando partições..."
mkfs.fat -F32 ${DISK}1
mkfs.btrfs -f ${DISK}2

# Montar partições
echo "Montando partições..."
mount ${DISK}2 /mnt

# Criar subvolumes btrfs
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
umount -R /mnt

# Remontar btrfs
mount -o compress=zstd,subvol=@ ${DISK}2 /mnt
mkdir -p /mnt/home
mount -o compress=zstd,subvol=@home ${DISK}2 /mnt/home
mkdir -p /mnt/efi
mount ${DISK}1 /mnt/efi

# Instalar o sistema base
echo "Instalando o sistema base..."
pacstrap -K /mnt base base-devel linux linux-firmware git btrfs-progs grub efibootmgr grub-btrfs inotify-tools timeshift vim networkmanager pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber reflector zsh zsh-completions zsh-autosuggestions openssh man sudo

# Gerar fstab
echo "Gerando fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Entrar no sistema instalado (chroot)
echo "Entrando no sistema instalado (chroot)..."
arch-chroot /mnt 
