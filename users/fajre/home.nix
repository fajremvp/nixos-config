{ config, pkgs, ... }:

{
  # Importa as "Features" (Módulos opt-in)
  imports = [
    ./features/niri.nix
    ./features/kitty.nix
    ./features/hyprlock.nix
    ./features/hypridle.nix
    ./features/nvim.nix
    ./features/mpv.nix
    ./features/cava.nix
    ./features/luz-noturna.nix
    ./features/hyprrun.nix
  ];

  home.username = "fajre";
  home.homeDirectory = "/home/fajre";

  # LISTA DE COMPRAS DE PACOTES
  # O Nix vai baixar e colocar no $PATH automaticamente
  home.packages = with pkgs; [
    firefox chromium tor-browser
    obsidian
    obs-studio kdePackages.kdenlive pavucontrol
    libreoffice hunspellDicts.pt-br
    prismlauncher
    drawio zathura qimgv
    veracrypt sparrow feather bisq2
    simplex-chat-desktop
    proton-vpn qbittorrent
    awww
    git pre-commit gitleaks nmap
    vim btop fastfetch tree fzf wl-clipboard
    _7zz unzip zip
    jdk21 maven netbeans xwayland-satellite
    nodejs
  ];

  # Permite que o Home Manager instale e gerencie a si mesmo
  programs.home-manager.enable = true;

  # Habilita o Syncthing como serviço de usuário
  services.syncthing = {
    enable = true;
  };

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

  # --- APLICATIVOS PADRÃO (MIME Types) ---
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # --- NAVEGADOR PADRÃO ---
      "text/html" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/about" = [ "firefox.desktop" ];
      "x-scheme-handler/unknown" = [ "firefox.desktop" ];

      # Pastas
      "inode/directory" = [ "thunar.desktop" ];

      # PDFs
      "application/pdf" = [ "org.pwmt.zathura.desktop" ];

      # Imagens (Tem que ser explícito, o Home Manager não suporta *)
      "image/jpeg" = [ "qimgv.desktop" ];
      "image/png"  = [ "qimgv.desktop" ];
      "image/gif"  = [ "qimgv.desktop" ];
      "image/webp" = [ "qimgv.desktop" ];
      "image/bmp"  = [ "qimgv.desktop" ];
      "image/svg+xml" = [ "qimgv.desktop" ];

      # Textos, Códigos e Markdown
      "text/plain" = [ "nvim-kitty.desktop" ];
      "text/markdown" = [ "nvim-kitty.desktop" ];
      "application/json" = [ "nvim-kitty.desktop" ];
      "text/x-c" = [ "nvim-kitty.desktop" ];
      "text/x-java" = [ "nvim-kitty.desktop" ];
      "text/x-python" = [ "nvim-kitty.desktop" ];
      "application/x-shellscript" = [ "nvim-kitty.desktop" ];
    };
  };

  # --- VARIÁVEIS DE SESSÃO GLOBAIS ---
  home.sessionVariables = {
    BROWSER = "firefox";
  };

  # --- ATALHOS CUSTOMIZADOS (Workarounds) ---
  xdg.desktopEntries = {
    # Truque para o Thunar conseguir abrir arquivos de texto no Neovim dentro do Kitty
    nvim-kitty = {
      name = "Neovim (Kitty)";
      exec = "kitty -e nvim %F";
      icon = "nvim";
      terminal = false; # false para o Thunar não tentar interceptar
      categories = [ "Utility" "TextEditor" ];
    };
  };

  home.stateVersion = "25.11";
}
