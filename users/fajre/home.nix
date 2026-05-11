{ config, pkgs, ... }:

{
  # Importa as "Features" (Módulos opt-in)
  imports = [
    ./features/niri.nix
    # ./features/kitty.nix
  ];

  home.username = "fajre";
  home.homeDirectory = "/home/fajre";

  # LISTA DE COMPRAS DE PACOTES
  # O Nix vai baixar e colocar no $PATH automaticamente
  home.packages = with pkgs; [
    firefox chromium tor-browser
    obs-studio drawio zathura
    veracrypt
    qbittorrent
    git pre-commit gitleaks nmap
    kitty vim neovim btop fastfetch tree fzf
    awww hyprlock
    _7zz unzip zip
    jdk21 maven netbeans
  ];

  # Permite que o Home Manager instale e gerencie a si mesmo
  programs.home-manager.enable = true;

  # Habilita o Syncthing como serviço de usuário
  services.syncthing = {
    enable = true;
  };

  services.hypridle.enable = true;

  systemd.user.services.awww = {
    Unit = {
      Description = "Animated Wayland Wallpaper Daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.awww}/bin/awww-daemon";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "niri.service" ]; # Amarra o serviço ao Niri
    };
  };

  home.stateVersion = "25.11";
}
