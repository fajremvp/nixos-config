{ config, pkgs, ... }:

{
  home.file.".local/bin/hyprrun.sh" = {
    executable = true;
    text = ''
      apps=(
        "Firefox:firefox"
        "Chromium:chromium"
        "Tor Browser:tor-browser"
        "LibreOffice:libreoffice"
        "NetBeans:netbeans"
        "Prism Launcher:prismlauncher"
        "OBS:obs"
        "Blueman:blueman-manager"
        "Pavucontrol:pavucontrol"
        "qBittorrent:qbittorrent"
        "ProtonVPN:protonvpn-app"
        "Sparrow Wallet:X"
        "Feather Wallet:X"
        "VeraCrypt:veracrypt"
        "draw.io:drawio"
        "KdenLive:kdenlive"
      )

      # ''$ no array para o Nix não tentar interpretar como variável Nix
      choice=$(printf "%s\n" "''${apps[@]}" | cut -d: -f1 | fzf --prompt="  ")

      if [ -n "$choice" ]; then
        cmd=$(printf "%s\n" "''${apps[@]}" | grep "^$choice:" | cut -d: -f2)

        # Executes the app, fully detaching it from the terminal
        setsid sh -c "$cmd >/dev/null 2>&1 &"
      fi
    '';
  };
}
