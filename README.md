# ❄️ OS as Code | NixOS & Home Manager

Este repositório contém a configuração declarativa completa dos meus sistemas operacionais e ambientes de usuário, gerenciados inteiramente via **Nix Flakes** e **Home Manager**.

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
│   └── acer-aspire/        # Meu notebook principal
│       ├── default.nix     # Configuração base, serviços, firewall, rede, boot e pacotes essenciais
│       └── hardware.nix    # Gerado via nixos-generate-config (Mapeia LUKS, BTRFS e Kernel modules)
├── users/                  # Configurações no nível do Usuário (via Home Manager)
│   └── fajre/              # Meu usuário principal
│       ├── home.nix        # Pacotes do usuário, variáveis de ambiente, atalhos, dotfiles globais e MIME types
│       └── features/       # Módulos opt-in gerenciados de forma declarativa
│           └── *.nix       # Módulos específicos isolados (Niri, Kitty, Neovim, MPV, etc)
├── secrets/                # Gerenciamento de segredos via SOPS (WIP)
│   ├── .sops.yaml          # Regras de criptografia e chaves PGP/Age
│   └── secrets.yaml        # Arquivo criptografado com chaves e senhas da infra
├── docs/                   # Documentação técnica e procedimentos operacionais
│   └── runbooks/           # Guias passo-a-passo (Instalação, Discos, etc)
├── .pre-commit-config.yaml # Hooks locais (Gitleaks, Shellcheck, Yamllint) para higiene de código
├── .gitignore              # Proteção extra contra vazamentos e lixo de sistema
├── LICENSE                 # MIT License
└── README.md               # Este arquivo
```

## 📚 Documentação e Runbooks

Os procedimentos operacionais padrão (SOPs) para instalação e manutenção do hardware físico estão documentados de forma imperativa e separada:

* [Guia de Instalação Bare-Metal (LUKS + BTRFS)](./docs/runbooks/01-install-bare-metal.md)
* [Adicionando Disco Secundário de Backup (LUKS2 + Keyfile)](./docs/runbooks/02-add-backup-disk.md)

---

**Nota sobre o Disko:** Embora a automação declarativa de discos com o [Disko](https://github.com/nix-community/disko) ser muito boa dentro do ecossistema NixOS para automatizar o particionamento de discos de forma declarativa, neste repositório eu preferi manter o processo imperativo documentado neste runbook. Ele faz mais sentido em cenários de provisionamento em massa, como várias máquinas iguais ou ambientes em nuvem. No caso de um único laptop, onde formatações são raras e o hardware pode mudar com o tempo, essa abstração acaba adicionando mais rigidez do que valor real. Por isso, o runbook já cumpre bem o papel de manter o processo reprodutível sem sacrificar flexibilidade.
