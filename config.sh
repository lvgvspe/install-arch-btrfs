

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
