{ config, pkgs, ... }:

{
  home.file.".local/bin/hyprrun.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      apps=(
        "Firefox:firefox"
        "Chromium:chromium"
        "Tor Browser:tor-browser"
	"Obsidian:obsidian"
        "LibreOffice:libreoffice"
        "NetBeans:netbeans"
        "Prism Launcher:prismlauncher"
        "OBS:obs"
        "Blueman:blueman-manager"
        "Pavucontrol:pavucontrol"
        "qBittorrent:qbittorrent"
        "ProtonVPN:protonvpn-app"
	"SimpleX:simplex-chat-desktop"
        "Sparrow Wallet:sparrow-desktop"
        "Feather Wallet:feather"
	"Bisq 2:bisq2"
        "Bisq 1:bisq-desktop"
        "VeraCrypt:veracrypt"
        "draw.io:drawio"
        "Kdenlive:kdenlive"
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
