# Script de Instalação do Arch Linux

Este repositório contém um script em Bash para automatizar a instalação do Arch Linux com base nas instruções fornecidas [neste guia](https://gist.github.com/mjkstra/96ce7a5689d753e7a6bdd92cdc169bae).

## Como Usar

1. **Inicialize o Ambiente Live do Arch Linux**:
   - Baixe a ISO do Arch Linux no [site oficial](https://www.archlinux.org/download/).
   - Crie uma mídia bootável (pendrive) e inicialize o ambiente live.

2. **Conecte-se à Internet**:
   - Para Wi-Fi, use o `iwctl`:
     ```bash
     iwctl
     station wlan0 connect <SSID>
     ```
   - Para conexões com fio, a rede deve ser configurada automaticamente.

3. **Baixe e Execute o Script**:
   - Execute o seguinte comando para baixar e rodar o script diretamente:
     ```bash
     curl -sSL https://raw.githubusercontent.com/lvgvspe/install-arch-btrfs/main/install_arch.sh | bash
     ```
   - Substitua a URL pelo link direto do seu script no GitHub.

4. **Siga as Instruções**:
   - O script guiará você pelo particionamento, formatação e instalação do Arch Linux.
   - Você será solicitado a fornecer detalhes como o disco a ser particionado, nome do host (hostname) e senha do root.

5. **Reinicie o Sistema**:
   - Após a conclusão do script, reinicie o sistema:
     ```bash
     reboot
     ```

## Observações
- **Conexão com a Internet**: Certifique-se de ter uma conexão ativa antes de executar o script.
- **Backup**: Sempre faça backup dos seus dados antes de prosseguir com a instalação.
- **Personalização**: Revise e personalize o script conforme necessário para o seu hardware e preferências.

## Licença
Este projeto está licenciado sob a MIT License. Consulte o arquivo [LICENSE](LICENSE) para mais detalhes.

## Contribuições
Contribuições são bem-vindas! Abra uma issue ou envie um pull request para melhorias ou correções de bugs.

---

**Aviso Legal**: Este script é fornecido "como está". Use-o por sua conta e risco. Sempre revise o script e certifique-se de que ele atenda às suas necessidades antes de executá-lo.
