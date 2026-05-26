# ❄️ OS as Code | NixOS & Home Manager

Bem-vindo ao repositório do meu desktop. Este repositório contém a configuração declarativa completa dos meus sistemas operacionais e ambientes de usuário, gerenciados inteiramente via **Nix Flakes** e **Home Manager**.

## 🧠 Filosofia: Por que NixOS?

Como tenho interesse em Infraestrutura e DevOps, eu convivo diariamente com ferramentas como Terraform e Ansible para garantir que servidores e nuvens sejam criados de forma previsível, imutável e versionada.

No entanto, me incomondava olhar para o meu próprio desktop e ver configurações espalhadas, dependências fantasmas e o temido *ClickOps*.
Eu já utilizava o modelo de dotfiles com [Arch Linux + Chezmoi](https://github.com/fajremvp/dotfiles), o que resolvia o problema no nível do usuário (dotfiles). Mas o sistema base ainda era mutável e sujeito a quebras.

O NixOS eleva essa filosofia ao nível do sistema operacional. Com este repositório, eu consigo:
* **Reprodutibilidade:** Clonar este repositório em um hardware novo e ter uma réplica do meu ambiente idêntica do meu ambiente em minutos.
* **Imutabilidade e Rollbacks:** O sistema nunca "apodrece" ou quebra permanentemente. Se uma atualização falhar, eu simplesmente dou boot na geração anterior no GRUB/systemd-boot.
* **Single Source of Truth (SSOT):** A infraestrutura (rede, serviços, drivers) e o ambiente de usuário (temas, atalhos, pacotes) vivem no mesmo código.

## 🏗️ Estrutura do Repositório

A arquitetura foi desenhada para ser modular, separando responsabilidades do sistema operacional e configurações de usuário, escalando facilmente para múltiplas máquinas.

```bash
.
├── flake.nix               # O coração de tudo: Define as entradas (Nixpkgs) e saídas (Hosts e Home Manager)
├── flake.lock              # Pinagem de versões: Garante reprodutibilidade travando as hashes das dependências
├── hosts/                  # Configurações no nível do Sistema Operacional (Root / Systemd)
│   ├── acer-aspire/        # Meu notebook principal
│   │   ├── default.nix     # Configuração base, serviços, firewall, rede, boot e pacotes essenciais
│   │   └── hardware.nix    # Gerado via nixos-generate-config (Mapeia LUKS, BTRFS e Kernel modules)
│   └── homelab-vm/         # Host: Máquina virtual do meu Homelab.
│       └── default.nix     # Configurações de sistema isoladas da VM.
├── users/                  # Configurações no nível do Usuário (via Home Manager)
│   └── fajre/              # Meu usuário principal
│       ├── home.nix        # Pacotes do usuário, variáveis de ambiente, atalhos, dotfiles globais e MIME types
│       └── features/       # Módulos opt-in gerenciados de forma declarativa
│           └── *.nix       # Módulos específicos isolados (Niri, Kitty, Neovim, MPV, etc)
├── secrets/                # Gerenciamento de segredos via SOPS (WIP)
│   ├── .sops.yaml          # Regras de criptografia e chaves PGP/Age
│   └── secrets.yaml        # Arquivo criptografado com chaves e senhas da infra
├── .pre-commit-config.yaml # Hooks locais (Gitleaks, Shellcheck, Yamllint) para higiene de código
├── .gitignore              # Proteção extra contra vazamentos e lixo de sistema
├── LICENSE                 # MIT License
└── README.md               # Este arquivo
```

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

---

**Nota:** Futuramente pretendo migrar para o [Disko](https://github.com/nix-community/disko), permitindo automatizar completamente o provisionamento do disco e a instalação do sistema com um único comando.
