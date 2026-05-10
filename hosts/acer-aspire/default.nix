{ config, pkgs, ... }:

{
  imports = [
    # ./hardware.nix # <- Gerado automaticamente na instalação do NixOS.
  ];

  # Identidade da Máquina na Rede
  networking.hostName = "acer-aspire";

  # Localização e Fuso Horário
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";

  # Habilitar Flakes nativamente no sistema
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # --- Configurações Gráficas e Wayland ---
  # Habilita o suporte a gráficos (OpenGL/Mesa)
  hardware.opengl.enable = true;
  # Instala e configura o Niri no nível do SO.
  programs.niri.enable = true;
  # Essencial para gerenciadores de janelas rodarem bem sem um Desktop Environment
  security.polkit.enable = true;

  # Usuário Root / Sistema Base
  users.users.fajre = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "docker" ]; # wheel = sudo
  };

  # Versão do Estado do Sistema
  system.stateVersion = "25.11"; 
}
