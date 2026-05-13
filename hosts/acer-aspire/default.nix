{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix # <- Gerado automaticamente na instalação do NixOS.
  ];

  # BOOTLOADER (UEFI)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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

  # --- Áudio (PipeWire) ---
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- Docker ---
  virtualisation.docker.enable = true;

  # --- XDG Portals (Para o OBS e File Picker funcionarem no Wayland) ---
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
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
