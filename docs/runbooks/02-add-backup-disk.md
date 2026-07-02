## 💾 Adicionando Disco Secundário de Backup (LUKS2 + Keyfile Auto-Unlock) (Runbook)

Este runbook documenta o processo imperativo e declarativo para adicionar um HD mecânico secundário de 1TB (`/dev/sda`) dedicado a backups, utilizando criptografia forte (AES-XTS-512) e desbloqueio automático em cascata gerenciado pelo estágio inicial de boot do NixOS (initrd).

### Fase 1: Particionamento e Configuração do LUKS2
1. Entrar como root e configure a tabela de partição GPT ocupando 100% do disco:
   ```bash
   sudo parted /dev/sda -- mklabel gpt
   sudo parted -a optimal /dev/sda -- mkpart primary 0% 100%
   ```
2. Formatar a partição com criptografia LUKS2 otimizada para setores de 4K:
   ```bash
   sudo cryptsetup luksFormat --type luks2 --sector-size 4096 -s 512 -c aes-xts-plain64 /dev/sda1
   ```
3. Abrir o cofre manualmente e formatar em Ext4 (o parâmetro -m 1 reserva apenas 1% para o root, liberando mais espaço útil em discos grandes):
   ```bash
   sudo cryptsetup open /dev/sda1 cryptbackup
   sudo mkfs.ext4 -m 1 -L BACKUP-HD /dev/mapper/cryptbackup
   ```
### Fase 2: Geração de Chave (Keyfile) e Redundância

Para evitar digitar a senha do SSD e do HD separadamente no boot, criar uma chave aleatória e embutimos o desbloqueio no initrd.

1. Faça o backup do cabeçalho do LUKS (crítico contra corrupção física de blocos):
    ```bash
    sudo cryptsetup luksHeaderBackup /dev/sda1 --header-backup-file ~/Important/aceraspire-hd-luks-header-backup-sda1.img
    ```
2. Gerar uma chave binária aleatória de 4096 bits com permissões estritas de leitura:
    ```bash
    sudo mkdir -p /etc/secrets
    sudo dd if=/dev/urandom of=/etc/secrets/cryptbackup.key bs=512 count=8
    sudo chmod 400 /etc/secrets/cryptbackup.key
    ```
3. Adicionar essa chave criptográfica como um método válido de abertura no slot livre do HD:
    ```bash
    sudo cryptsetup luksAddKey /dev/sda1 /etc/secrets/cryptbackup.key
    ```
### Fase 3: Declaração no NixOS (`hosts/acer-aspire/default.nix`)

Colar os UUIDs coletados via `sudo blkid /dev/sda1` (partição física) e `sudo blkid /dev/mapper/cryptbackup` (sistema de arquivos lógico) na raiz da configuração do host:

    ```nix
    # Injeta o arquivo de chave dentro da RAM de boot (initrd) antes do mount da raiz
    boot.initrd.secrets = {
       "/etc/secrets/cryptbackup.key" = "/etc/secrets/cryptbackup.key";
    };

    # Descriptografia do hardware via Keyfile
    boot.initrd.luks.devices."cryptbackup" = {
       device = "/dev/disk/by-uuid/COLOQUE_O_UUID_DO_LUKS_AQUI";
       keyFile = "/etc/secrets/cryptbackup.key";
       bypassWorkqueues = true; # Otimização de performance
    };

    # Montagem estável na árvore do sistema
    fileSystems."/mnt/backup-hd" = {
       device = "/dev/disk/by-uuid/COLOQUE_O_UUID_DO_EXT4_AQUI";
       fsType = "ext4";
       # 'nofail' impede o travamento do boot caso o HD secundário seja removido
       options = [ "defaults" "noatime" "nofail" ];
    };
    ```

### Fase 4: Deploy e Ajuste de Permissões de Usuário
1. Aplique a configuração no sistema:
    ```bash
    git add hosts/acer-aspire/default.nix
    sudo nixos-rebuild switch --flake .#acer-aspire
    ```
2. Fechar o mapeamento manual antigo e forçar o systemd a gerenciar o novo ponto de montagem:
    ```bash
    sudo cryptsetup close cryptbackup
    sudo systemctl daemon-reload
    sudo systemctl restart mnt-backup\\x2dhd.mount
    ```
3. Transferir a propriedade da pasta raiz do HD para o seu usuário do Home Manager:
    ```bash
    sudo chown -R fajre:users /mnt/backup-hd
    ```
