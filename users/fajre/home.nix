{ config, pkgs, ... }:

{
  # Importa as "Features" (Módulos opt-in)
  imports = [
    ./features/niri.nix
    ./features/kitty.nix
    ./features/hyprlock.nix
  ];

  home.username = "fajre";
  home.homeDirectory = "/home/fajre";

  # LISTA DE COMPRAS DE PACOTES
  # O Nix vai baixar e colocar no $PATH automaticamente
  home.packages = with pkgs; [
    firefox chromium tor-browser
    obs-studio drawio zathura
    veracrypt
    proton-vpn qbittorrent
    git pre-commit gitleaks nmap
    vim neovim btop fastfetch tree fzf
    awww
    _7zz unzip zip
    jdk21 maven netbeans xwayland-satellite
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

 # --- Configuração do Terminal (Bash) ---
  programs.bash = {
    enable = true;
    enableCompletion = true;

    # Seus Aliases
    shellAliases = {
      ls = "ls --color=auto";
      grep = "grep --color=auto";
    };

    initExtra = ''
      # Custom Prompt Dinâmico (PS1)
      PS1='\[\e[38;5;250m\]┌─(\[\e[1;37m\]\u\[\e[1;36m\]@\[\e[1;37m\]\h\[\e[0m\])-[\[\e[1;34m\]\w\[\e[0m\]]\n\[\e[38;5;250m\]└─\$ '
      export PATH="$HOME/.local/bin:$PATH"

      # Inicialização do NVM
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

      # Fix para aplicativos Java Swing em Tiling Window Managers
      export _JAVA_AWT_WM_NONREPARENTING=1
    '';
  };

  # --- Git ---
  programs.git = {
    enable = true;
    signing = {
      key = "AF15F5ED0960E69E";
      signByDefault = true;
    };
    settings = {
      user.name = "Fajre";
      user.email = "105254444+fajremvp@users.noreply.github.com";
      init.defaultBranch = "main";
    };
  };

  # --- GPG e Autenticação no Wayland ---
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 7200;
    pinentry.package = pkgs.pinentry-gnome3;
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
