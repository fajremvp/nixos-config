{ config, pkgs, ... }:

{
  # Isso cria o arquivo ~/.config/niri/config.kdl e injeta o texto dentro
  home.file.".config/niri/config.kdl".text = ''
// ---------------------------------------------------------
// NIRI CONFIGURATION - TRADUZINDO MEU HYPRLAND
// ---------------------------------------------------------
// Este arquivo utiliza a linguagem de marcação KDL.
// Toda configuração está dividida por nós e blocos.

prefer-no-csd

// --- STARTUP / EXEC-ONCE ---
// O Niri recomenda que ferramentas essenciais como barras e daemons sejam iniciadas na sua sessão (Wayland).
spawn-at-startup "hypridle"
spawn-at-startup "kitty" "-e" "btop"
spawn-at-startup "xwayland-satellite"

// Execução de script bash customizado
spawn-sh-at-startup "~/.local/bin/luz_noturna.sh reset"

// --- MONITOR (OUTPUTS) ---
// Substituindo o "monitor = HDMI-A-1..." do Hyprland.
// O Niri mapeia monitores individualmente.
output "eDP-1" {
    // Escala, resolução e posição.
    scale 1.0
    position x=0 y=0
}

output "HDMI-A-1" {
    scale 1.0
    position x=1366 y=-600
}

// --- INPUTS / TECLADO & MOUSE ---
input {

    focus-follows-mouse

    keyboard {
        xkb {
            // No Hyprland: kb_layout = br,us / kb_variant = abnt2, / kb_options = grp:win_space_toggle
            layout "br,us"
            variant "abnt2,"
            options "grp:win_space_toggle"
        }
    }
    // Configurações do Touchpad (No Hyprland: natural_scroll = false)
    touchpad {
        // off
        tap
        // natural-scroll // Mantido comentado para desativar.
    }
    // Configurações avançadas do Mouse (No Hyprland: sensitivity = -0.5 para o epic-mouse)
    // O Niri não suporta configurações por-device de forma tão nativa, portanto, é preciso ajustar a velocidade geral.
    mouse {
        // accel-speed -0.5
    }
}

// --- VISUAL (LOOK AND FEEL) E LAYOUT ---
// As bordas e cantos arredondados são definidos por layout e window-rules.
layout {
    // No Niri, 'gaps' aplica-se de forma geral. Para emular gaps_in e gaps_out distintos,
    // o Niri recomenda definir o gap interno e usar 'struts' negativos.
    // Usarei 10 de gap global (que visualmente cria 20 entre janelas).
    gaps 10

    // O Hyprland usa dwindle. O Niri foca em larguras proporcionais para a rolagem infinita.
    default-column-width { proportion 0.5; }

    preset-column-widths {
        proportion 0.33333
        proportion 0.5
        proportion 0.66667
    }

    // Configuração de bordas e foco (active_border / inactive_border)
    focus-ring {
        off
    }

    border {
        off
    }

    // Sombras (Shadows)
    shadow {
        off
    }

    background-color "transparent"
}

// Para o arredondamento dos cantos e transparência (Hyprland decoration).
window-rule {
    geometry-corner-radius 10
    clip-to-geometry true
}


// --- ATALHOS / BINDS ---
// O modificador no Niri é chamado de "Mod" (Super/Windows key).
binds {
    // Utilitários de Janela e Aplicações
    Mod+Q repeat=false { spawn "kitty"; }
    Mod+E { spawn "kitty" "-e" "yazi"; }
    Mod+C { close-window; }
    Mod+Shift+M { quit; }
    // Abre a Visão Geral (Overview)
    Mod+Escape repeat=false { toggle-overview; }

    // Script Executions com múltiplos parâmetros ou via bash
    Mod+B repeat=false { spawn-sh "kitty -e btop"; }
    Mod+L repeat=false { spawn "hyprlock"; }

    Mod+K { screenshot; } // Abre a UI interativa (seleção de área)
    Mod+Shift+K { screenshot-screen; } // Tira print da tela toda
    Mod+Ctrl+K { screenshot-window; } // Tira print apenas da janela em foco

    // Ajustes de Janela
    Mod+V repeat=false { maximize-column; }
    Mod+F repeat=false { maximize-window-to-edges; }
    Mod+Shift+F repeat=false { fullscreen-window; }

    Mod+P repeat=false { toggle-window-floating; }

    // Movimentação (Focus)
    Mod+A  { focus-column-left; }
    Mod+D  { focus-column-right; }
    Mod+W  { focus-workspace-up; }
    Mod+S  { focus-workspace-down; }

    // Atalhos de Mídia (Pipewire/Playerctl)
    XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1.0"; }
    XF86AudioLowerVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"; }
    XF86AudioMute        allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
    XF86AudioMicMute     allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }

    XF86MonBrightnessUp   allow-when-locked=true { spawn "brightnessctl" "-e4" "-n2" "set" "5%+"; }
    XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "-e4" "-n2" "set" "5%-"; }

    XF86AudioPlay allow-when-locked=true { spawn-sh "playerctl play-pause"; }
    XF86AudioNext allow-when-locked=true { spawn-sh "playerctl next"; }

    // --- Scripts e Comandos de Terminal Avançados ---
    Shift+F3 { spawn-sh "~/.local/bin/luz_noturna.sh down"; }
    Shift+F4 { spawn-sh "~/.local/bin/luz_noturna.sh up"; }
    // HyprRun
    Mod+R repeat=false { spawn "kitty" "-e" "/home/fajre/.local/bin/hyprrun.sh"; }
}

gestures {
    // Desativa completamente o acionamento de funções ao encostar o mouse nos cantos da tela
    hot-corners {
        off
    }
}

overview {
    zoom 0.4
}

layer-rule {
    match layer="background"
    place-within-backdrop true
}

hotkey-overlay {
    skip-at-startup
}

blur {
    passes 3
    offset 3.0
    noise 0.02
    saturation 1.0
}

window-rule {
    match app-id="^kitty$"
    background-effect {
        blur true
    }
}
'';
}
