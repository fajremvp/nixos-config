## 💿 Guia de Instalação Bare-Metal (Runbook)

Este guia documenta o processo exato de instalação deste repositório em uma máquina física do zero, utilizando **Criptografia LUKS** e **Subvolumes BTRFS** com compressão ZSTD.

### Fase 0: Preparação
1. Faça o download da **NixOS Minimal ISO** e grave em um pendrive:
   ```bash
   sudo dd if=nixos-minimal.iso of=/dev/sdc bs=4M status=progress
   sync
   ```
2. Dê boot na máquina via pendrive e conecte-se à internet.

### Fase 1: Particionamento (UEFI)
Nota: Neste exemplo, o disco alvo é o /dev/sdb.
1. Entra como root
   ```bash
   sudo su
   ```
2. Confirma conexão
   ```bash
   ping 1.1.1.1
   ```
3. Cria tabela GPT e partições (Boot e Root)
   ```bash
   parted /dev/sdb -- mklabel gpt
   parted /dev/sdb -- mkpart ESP fat32 1MiB 512MiB
   parted /dev/sdb -- set 1 esp on
   parted /dev/sdb -- mkpart primary 512MiB 100%
   ```
### Fase 2: LUKS e BTRFS com subvolumes
1. Formata e abre o volume criptografado LUKS
   ```bash
   cryptsetup luksFormat /dev/sdb2
   cryptsetup open /dev/sdb2 cryptroot
   ```
2. Formata as partições
   ```bash
   mkfs.fat -F 32 -n boot /dev/sdb1
   mkfs.btrfs -L nixos /dev/mapper/cryptroot
   ```
3. Criação dos Subvolumes BTRFS para flexibilidade e snapshots
   ```bash
   mount /dev/mapper/cryptroot /mnt
   btrfs subvolume create /mnt/@
   btrfs subvolume create /mnt/@home
   btrfs subvolume create /mnt/@nix
   umount /mnt
   ```
4. Montagem da estrutura final utilizando compressão ZSTD
   ```bash
   mount -o compress=zstd,subvol=@ /dev/mapper/cryptroot /mnt
   mkdir -p /mnt/{home,nix,boot}
   mount -o compress=zstd,subvol=@home /dev/mapper/cryptroot /mnt/home
   mount -o compress=zstd,subvol=@nix /dev/mapper/cryptroot /mnt/nix
   mount /dev/sdb1 /mnt/boot
   ```
### Fase 3: Geração de Hardware e Injeção no Flake
1. Gera as configurações do hardware mapeando o LUKS e os subvolumes
   ```bash
   nixos-generate-config --root /mnt
   ```
2. Sai do usuário root para usar o Git com segurança
   ```bash
   exit
   ```
3. Clona a infraestrutura
   ```bash
   git clone https://github.com/fajremvp/nixos-config.git ~/nixos-config
   cd ~/nixos-config
   ```
4. Injeta o hardware gerado no módulo correto
   ```bash
   cp /mnt/etc/nixos/hardware-configuration.nix ./hosts/acer-aspire/hardware.nix
   ```
5. Verifica dependências no default.nix e faz o commit
Observação: Flakes exigem que os arquivos estejam versionados no Git.
   ```bash
   git add .
   git commit -m "chore: inject bare-metal hardware config (LUKS+BTRFS)"
   ```
### Fase 4: Deploy
Inicia a instalação apontando para o host desejado
   ```bash
   sudo nixos-install --flake .#acer-aspire
   ```
O instalador irá compilar o sistema, instalar os pacotes declarados e, ao final, solicitará a senha de root.
Quando finalizar:
1. Digite `reboot` e remova o pendrive.
2. Insira a senha do disco LUKS durante o boot.
3. Logue no TTY (usuário fajre, senha inicial 123).
4. Execute `niri-session` para iniciar a interface gráfica.
