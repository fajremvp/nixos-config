{ config, pkgs, ... }:

{
  home.packages = [ pkgs.hyprlock ];

  # Injeta a configuração diretamente no caminho esperado pelo hyprlock
  home.file.".config/hypr/hyprlock.conf".text = ''

    general {
        hide_cursor = true
    }

    animations {
        enabled = true
        bezier = linear, 1, 1, 0, 0
        animation = fadeIn, 1, 5, linear
        animation = fadeOut, 1, 5, linear
        animation = inputFieldDots, 1, 2, linear
    }

    background {
        path = screenshot
        blur_passes = 2   # blur leve para enxergar o fundo
    }

    # CAMPO DE SENHA
    input-field {
        size = 22%, 6%
        outline_thickness = 0
        inner_color = rgba(0, 0, 0, 0)
        check_color = rgba(0, 0, 0, 0) rgba(0, 0, 0, 0) 120deg
        fail_color = rgba(255, 0, 0, 0) rgba(255, 0 , 0, 0) 40deg
        outer_color = rgba(0, 0, 0 , 0) rgba(0, 0, 0, 0) 45deg
        font_color = rgba(220, 220, 220, 0.7)
        fade_on_empty = false
        rounding = 15
        font_family = JetBrains Nerf Font
        placeholder_text =
        fail_text = Loser!
        dots_spacing = 0.3
        position = 0, -160
        halign = center
        valign = center
    }

    # HORA (com segundos)
    label {
        text = cmd[update:1000] date +"%H:%M:%S" # atualiza a cada segundo
        font_size = 90
        font_family = Minecraftia
        position = 0, 70
        halign = center
        valign = center
    }

    # DATA (em inglês)
    label {
        text = cmd[update:60000] date +"%A, %B %d"
        font_size = 28
        font_family = Minecraftia
        position = 0, -10
        halign = center
        valign = center
    }

    # TEXTO MEME “I use Nix, btw”
    label {
        # <span> para isolar a cor apenas na palavra "Nix"
        text = I use <span foreground="cyan">Nix</span>, btw

        font_size = 50
        font_family = JetBrains Nerf Font
        color = rgba(200, 200, 200, 1.0)
        position = 0, -80
        halign = center
        valign = center
    }
  '';
}
