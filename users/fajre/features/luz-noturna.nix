{ config, pkgs, ... }:

{
  # Instala o wlsunset no sistema
  home.packages = [ pkgs.wlsunset ];

  # Cria o script exatamente como era no Arch, e já aplica o "chmod +x" nele
  home.file.".local/bin/luz_noturna.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      STATE="$HOME/.cache/current_temp"
      DEFAULT_TEMP=3000
      STEP=200
      MIN=2000
      MAX=6500

      [ -f "$STATE" ] || echo $DEFAULT_TEMP > "$STATE"
      TEMP=$(cat "$STATE")

      case "$1" in
        up)
          TEMP=$((TEMP + STEP))
          [ $TEMP -gt $MAX ] && TEMP=$MAX
          ;;
        down)
          TEMP=$((TEMP - STEP))
          [ $TEMP -lt $MIN ] && TEMP=$MIN
          ;;
        reset)
          TEMP=$DEFAULT_TEMP
          ;;
        *)
          echo "Uso: $0 [up|down|reset]"
          exit 1
          ;;
      esac

      echo $TEMP > "$STATE"

      # Desliga o wlsunset anterior
      pkill wlsunset

      # Força temperatura fixa SEM horário solar
      wlsunset -t "$TEMP" -d "$TEMP" -S 12:00 -s 12:01 & disown

      # Notificação
      # notify-send "Luz noturna: $TEMP K"
    '';
  };
}
