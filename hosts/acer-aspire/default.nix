{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix # <- Gerado automaticamente na instalação do NixOS.
  ];

  # BOOTLOADER (UEFI)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Habilita o zRAM como swap comprimido na memória.
  # O NixOS automaticamente calcula uma porcentagem segura da sua RAM (geralmente 50%, ou seja, ~8GB virtuais).
  zramSwap.enable = true;

  # Identidade da Máquina na Rede
  networking.hostName = "acer-aspire";
  networking.networkmanager.enable = true;

  # Localização e Fuso Horário
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";

  # --- Configurações Básicas do Nix ---
  # Permite a instalação de pacotes e drivers proprietários
  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      # Habilita Flakes
      experimental-features = [ "nix-command" "flakes" ];
      # Desativa o registro global para garantir que os pacotes venham estritamente do seu flake.lock
      flake-registry = "";
    };
    # Desativa os canais legados. O sistema será 100% gerenciado via Flakes
    channel.enable = false;
  };

  # --- Configurações Gráficas e Wayland ---
  # Habilita o suporte a gráficos (OpenGL/Mesa)
  hardware.graphics.enable = true;
  # Instala e configura o Niri no nível do SO.
  programs.niri.enable = true;
  # Essencial para gerenciadores de janelas rodarem bem sem um Desktop Environment
  security.polkit.enable = true;
  # Permite que o Hyprlock valide a sua senha (PAM)
  security.pam.services.hyprlock = {};

  # --- Áudio (PipeWire) ---
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- BLUETOOTH ---
  hardware.bluetooth.enable = true; # Liga o suporte ao hardware
  hardware.bluetooth.powerOnBoot = false; # Eu ligo manualmente
  services.blueman.enable = true; # Habilita o daemon e as permissões do Blueman

  # --- Docker ---
  virtualisation.docker.enable = true;
  # Força o systemd a NÃO iniciar o docker ou seu socket automaticamente no boot
  systemd.services.docker.wantedBy = pkgs.lib.mkForce [ ];
  systemd.sockets.docker.wantedBy = pkgs.lib.mkForce [ ];

  # --- XDG Portals (Para o OBS e File Picker funcionarem no Wayland) ---
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # --- GERENCIADOR DE ARQUIVOS (Thunar) ---
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  # GVFS garante que a Lixeira, montagem de pendrives e discos de rede funcionem
  services.gvfs.enable = true;
  # Tumbler gera as miniaturas (thumbnails) das imagens
  services.tumbler.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
    minecraftia
  ];

  # Camada de compatibilidade X11 (Crítico para OBS, Java e Electron)
  programs.xwayland.enable = true;

  hardware.enableRedistributableFirmware = true;

  # Habilita o daemon do Tailscale
  services.tailscale.enable = true;

  # Serviços de Segurança do GNOME (Necessário para o Proton VPN salvar senhas)
  services.gnome.gnome-keyring.enable = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false; # Foco em segurança (apenas chaves)
  };

  networking = {
    nftables.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
      # Confia totalmente na interface Tailscale
      trustedInterfaces = [ "tailscale0" ];
      # Logs
      logRefusedConnections = true;
    };
  };

  # Usuário Root / Sistema Base
  users.users.fajre = {
    initialPassword = "123";
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "docker" ]; # wheel = sudo
  };

  # Versão do Estado do Sistema
  system.stateVersion = "25.11";
}
