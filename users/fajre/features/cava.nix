{ config, pkgs, ... }:

{
  home.packages = [ pkgs.cava ];

  # Injeta a configuração original no caminho padrão do CAVA
  home.file.".config/cava/config".text = ''
    [general]
    framerate = 60
    autosens = 0
    sensitivity = 80
    bars = 0
    bar_width = 2
    bar_spacing = 1
    lower_cutoff_freq = 50
    higher_cutoff_freq = 12000

    [color]
    background = default
    gradient = 1
    gradient_color_1 = '#9ab6d3'   # azul claro
    gradient_color_2 = '#7da4c4'   # azul acinzentado
    gradient_color_3 = '#6a8faa'   # azul/cinza médio
    gradient_color_4 = '#5a7d9a'   # azul mais escuro
    gradient_color_5 = '#3b4d61'   # cinza azulado escuro
    gradient_color_6 = '#2f3e4f'   # cinza bem escuro
    gradient_color_7 = '#1c1f26'   # quase preto

    [smoothing]
    noise_reduction = 85
    monstercat = 1
    waves = 0

    [eq]
    1 = 1.0    # graves
    2 = 0.8
    3 = 0.7
    4 = 0.65
    5 = 0.6    # agudos
  '';
}
