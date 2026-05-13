{ config, pkgs, ... }:

{
  home.packages = [ pkgs.hypridle ];

  services.hypridle = {
    enable = true;

    settings = {
      general = {
	# Evita rodar o hyprlock duas vezes se já estiver bloqueado
        lock_cmd = "pidof hyprlock || hyprlock";
      };

      listener = [
        {
          timeout = 300;			# 5 minutos
          on-timeout = "loginctl lock-session"; # Bloqueia a tela
        }
      ];
    };
  };
}
