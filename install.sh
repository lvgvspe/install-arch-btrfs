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
loadkeys us

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
mkdir /mnt/boot
mount ${DISK}1 /mnt/boot

# Instalar o sistema base
echo "Instalando o sistema base..."
pacstrap /mnt base linux linux-firmware btrfs-progs

# Gerar fstab
echo "Gerando fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Entrar no sistema instalado (chroot)
echo "Entrando no sistema instalado (chroot)..."
arch-chroot /mnt <<EOF

# Configurar o fuso horário
echo "Configurando o fuso horário para America/Sao_Paulo..."
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
hwclock --systohc

# Configurar o locale
echo "Configurando o locale para pt_BR.UTF-8..."
echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=pt_BR.UTF-8" > /etc/locale.conf

# Configurar o layout do teclado
echo "Configurando o layout do teclado para BR-ABNT2..."
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

# Instalar o GRUB (bootloader)
echo "Instalando o GRUB..."
pacman -S grub --noconfirm
grub-install --target=i386-pc $DISK
grub-mkconfig -o /boot/grub/grub.cfg

# Instalar pacotes adicionais (opcional)
echo "Instalando pacotes adicionais (opcional)..."
pacman -S networkmanager sudo vim --noconfirm

# Habilitar o NetworkManager
echo "Habilitando o NetworkManager..."
systemctl enable NetworkManager

# Criar um novo usuário
echo "Criando um novo usuário..."
echo "Por favor, insira o nome de usuário:"
read USERNAME
useradd -m -G wheel -s /bin/bash $USERNAME
echo "Por favor, defina uma senha para o novo usuário:"
passwd $USERNAME

# Configurar o sudo para o novo usuário
echo "Configurando o sudo para o novo usuário..."
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

EOF

# Finalizar a instalação
echo "Instalação concluída!"
echo "Desmontando partições..."
umount -R /mnt
echo "Agora você pode reiniciar o sistema:"
echo "1. Digite 'exit' para sair do ambiente chroot."
echo "2. Execute 'reboot' para reiniciar o sistema."
