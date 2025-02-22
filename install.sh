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
echo "Entrando no sistema instalado e continuando o código de configuração..."
echo "Execute o seguinte comando para continuar a configuração:"
echo "curl -sSL https://raw.githubusercontent.com/lvgvspe/install-arch-btrfs/main/config.sh -o config.sh && bash config.sh"
arch-chroot /mnt
