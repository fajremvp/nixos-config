{ config, pkgs, ... }:

{
  # Importa as "Features" (Módulos opt-in)
  imports = [
    ./features/niri.nix
    # ./features/kitty.nix
    # ./features/git.nix
  ];

  home.username = "fajre";
  home.homeDirectory = "/home/fajre";

  # LISTA DE COMPRAS DE PACOTES
  # O Nix vai baixar e colocar no $PATH automaticamente
  home.packages = with pkgs; [
    firefox
    kitty
    btop
    fastfetch
    awww
    wl-clipboard
    # Adicinar outros pacotes de uso diário aqui...
  ];

  # Permite que o Home Manager instale e gerencie a si mesmo
  programs.home-manager.enable = true;

  home.stateVersion = "25.11";
}
