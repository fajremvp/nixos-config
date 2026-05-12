{ config, pkgs, ... }:

{
  # Importa as "Features" (Módulos opt-in)
  imports = [
    ./features/niri.nix
    ./features/kitty.nix
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
    vim neovim btop fastfetch tree fzf
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

  # --- Git ---
  programs.git = {
    enable = true;
    userName = "Fajre";
    userEmail = "105254444+fajremvp@users.noreply.github.com";
    signing = {
      key = "AF15F5ED0960E69E";
      signByDefault = true;
    };
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  # --- GPG e Autenticação no Wayland ---
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 7200;
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  # --- Configuração do Cursor ---
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  home.stateVersion = "25.11";
}
