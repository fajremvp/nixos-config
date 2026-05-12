{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = true;

    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };

    settings = {
      background_opacity = "0.8";
      cursor_trail = "1";
      cursor_shape = "block";
      hide_window_decorations = "yes";
    };

    extraConfig = ''
      line_spacing 0.0
    '';
  };
}
