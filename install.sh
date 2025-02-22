#!/bin/bash

# Script de instalação do Arch Linux

# Verificar se o usuário é root
if [[ $EUID -ne 0 ]]; then
   echo "Este script deve ser executado como root" 
   exit 1
fi

# Configuração do teclado
echo "Configurando o teclado para pt_BR"
loadkeys br-abnt2

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

echo "Deseja usar o esquema de partição GPT? (s/n)"
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
echo "2. Partição swap (2G)"
echo "3. Partição raiz (restante do espaço)"

parted $DISK mkpart primary fat32 1MiB 513MiB
parted $DISK set 1 boot on
parted $DISK mkpart primary linux-swap 513MiB 2.5GiB
parted $DISK mkpart primary ext4 2.5GiB 100%

# Formatar partições
echo "Formatando partições..."
mkfs.fat -F32 ${DISK}1
mkswap ${DISK}2
mkfs.ext4 ${DISK}3

# Montar partições
echo "Montando partições..."
mount ${DISK}3 /mnt
mkdir /mnt/boot
mount ${DISK}1 /mnt/boot
swapon ${DISK}2

# Instalar o sistema base
echo "Instalando o sistema base..."
pacstrap /mnt base linux linux-firmware

# Gerar fstab
echo "Gerando fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Entrar no sistema instalado
echo "Entrando no sistema instalado..."
arch-chroot /mnt

# Configurar o fuso horário
echo "Configurando o fuso horário para America/Sao_Paulo..."
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc

# Configurar o locale
echo "Configurando o locale para pt_BR..."
echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=pt_BR.UTF-8" > /etc/locale.conf

# Configurar o teclado
echo "Configurando o teclado para br-abnt2..."
echo "KEYMAP=br-abnt2" > /etc/vconsole.conf

# Configurar o hostname
echo "Por favor, insira o nome do host:"
read HOSTNAME
echo $HOSTNAME > /etc/hostname

# Configurar a rede
echo "Configurando a rede..."
echo "127.0.0.1   localhost" >> /etc/hosts
echo "::1         localhost" >> /etc/hosts
echo "127.0.1.1   $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

# Definir senha do root
echo "Definindo a senha do root..."
passwd

# Instalar o bootloader (GRUB)
echo "Instalando o GRUB..."
pacman -S grub
grub-install --target=i386-pc $DISK
grub-mkconfig -o /boot/grub/grub.cfg

# Finalizar a instalação
echo "Instalação concluída!"
echo "Digite 'exit' para sair do chroot e reinicie o sistema."
