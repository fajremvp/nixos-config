{ config, pkgs, ... }:

{
  home.packages = [ pkgs.waybar ];

  # --- CONFIGURAÇÃO DA BARRA (JSONC) ---
  home.file.".config/waybar/config".text = ''
    {
      "layer": "top",
      "position": "top",
      "height": 26,
      "spacing": 5,
      "output": "eDP-1",

      "modules-left": [
        "battery",
        "cpu",
        "memory",
        "temperature",
        "custom/uptime"
      ],

      "modules-right": [
        "pulseaudio",
        "custom/wlsunset",
        "niri/language",
        "bluetooth",
        "custom/protonvpn",
        "custom/tailscale",
        "network",
        "clock"
      ],

      // --- Módulos da Esquerda ---
      "battery": {
        "states": {
          "warning": 30,
          "critical": 15
        },
        "format": "{icon} {capacity}%",
        "format-charging": " {capacity}%",
        "format-plugged": " {capacity}%",
        "format-icons": ["", "", "", "", ""],
        "on-click": "kitty --override font_size=10 -e btop"
      },
      "cpu": {
        "format": " {usage}%",
        "tooltip": false,
        "on-click": "kitty --override font_size=10 -e btop"
      },
      "memory": {
        "format": "󰍛 {}%",
        "on-click": "kitty --override font_size=10 -e btop"
      },
      "temperature": {
        "hwmon-path": "/sys/class/hwmon/hwmon2/temp1_input",
        "critical-threshold": 75,
        "format": "{temperatureC}°C",
        "on-click": "kitty --override font_size=10 -e btop"
      },
      "custom/uptime": {
        "format": "↑ {}",
        "exec": "awk '{d=int($1/86400); h=int(($1%86400)/3600); m=int(($1%3600)/60); if(d>0) printf \"%dd \", d; printf \"%dh%dm\\n\", h, m}' /proc/uptime",
        "interval": 60,
        "on-click": "kitty --override font_size=10 -e btop"
      },

      // --- Módulos da Direita ---
      "pulseaudio": {
        "format": "{icon}  {volume}%",
        "format-muted": "󰖁 Muted",
        "format-icons": {
          "default": ["", "", ""]
        }
      },
      "custom/wlsunset": {
        "format": "{}K",
        "exec": "cat ~/.cache/current_temp 2>/dev/null || echo '3000'",
        "interval": 2,
        "on-click": "~/.local/bin/luz_noturna.sh reset",
        "on-scroll-up": "~/.local/bin/luz_noturna.sh up",
        "on-scroll-down": "~/.local/bin/luz_noturna.sh down"
      },
      "niri/language": {
        "format": "{}",
        "format-en": "US",
        "format-pt": "BR"
      },
      "bluetooth": {
        "format": " {status}",
        "format-connected": " {device_alias}",
        "on-click": "blueman-manager"
      },
      "custom/protonvpn": {
  	"format": "{}",
	"exec": "ip link show proton0 >/dev/null 2>&1 && echo VPN ON || echo VPN OFF",
	"interval": 5,
	"on-click": "protonvpn-app"
      },
      "custom/tailscale": {
        "format": "{}",
        "exec": "tailscale status >/dev/null 2>&1 && echo 'Tailscale ON' || echo 'Tailscale OFF'",
	"interval": 5
      },
      "network": {
        "format-wifi": " {essid}",
        "format-ethernet": "󰈀 {ipaddr}",
        "format-disconnected": "⚠ Disconnected",
        "tooltip-format": "{ipaddr}/{cidr}",
        "on-click": "kitty -e nmtui"
      },
      "clock": {
        "format": "{:%a, %b %d %H:%M}",
        "tooltip-format": "<tt><small>{calendar}</small></tt>"
      }
    }
  '';

  # --- ESTILIZAÇÃO CSS ---
  home.file.".config/waybar/style.css".text = ''
    * {
      font-family: "JetBrainsMono Nerd Font";
      font-size: 13px;
      min-height: 0;
    }

    window#waybar {
      background: rgba(20, 20, 20, 0.8);
      color: #cdd6f4;
    }

    /* Módulos ordenados da Esquerda para a Direita */
    #battery, #cpu, #memory, #temperature, #custom-uptime, #pulseaudio, #custom-wlsunset, #language, #bluetooth, #custom-protonvpn, #custom-tailscale, #network, #clock {
      padding: 0 10px;
      margin: 4px 4px;
      border-radius: 8px;
      background-color: #313244;
      color: #cdd6f4;
    }

    #battery.charging {
      color: #a6e3a1;
    }

    #battery.critical:not(.charging) {
      background-color: #f38ba8;
      color: #1e1e2e;
    }

    #temperature.critical {
      background-color: #f38ba8;
      color: #1e1e2e;
    }
  '';
}
