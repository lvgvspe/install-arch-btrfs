
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
echo "Configurando o layout do teclado para BR-ABNT..."
echo "KEYMAP=br-abnt" > /etc/vconsole.conf

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

# Criar um novo usuário
echo "Criando um novo usuário..."
echo "Por favor, insira o nome de usuário:"
read USERNAME
useradd -m -G wheel -s /bin/bash $USERNAME
echo "Por favor, defina uma senha para o novo usuário:"
passwd $USERNAME

# Instalar pacotes adicionais (opcional)
echo "Instalando pacotes adicionais (opcional)..."
pacman -S networkmanager sudo nano --noconfirm

# Habilitar o NetworkManager
echo "Habilitando o NetworkManager..."
systemctl enable NetworkManager

# Configurar o sudo para o novo usuário
echo "Configurando o sudo para o novo usuário..."
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Instalar o GRUB (bootloader)
echo "Instalando o GRUB..."
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB  
grub-mkconfig -o /boot/grub/grub.cfg

# Finalizar a instalação
echo "Instalação concluída!"
echo "Agora você pode reiniciar o sistema:"
echo "1. Digite 'exit' para sair do ambiente chroot."
echo "2. Execute 'reboot' para reiniciar o sistema."
