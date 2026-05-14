{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    # Silencia os warnings e adota a prática moderna do Nix
    withRuby = false;
    withPython3 = false;

    # O Nix garante que o Neovim sempre terá essas ferramentas disponíveis no PATH dele, isolando do resto do sistema.
    extraPackages = with pkgs; [
      # Essenciais para o Telescope
      ripgrep
      fd

      # Essenciais para o Treesitter compilar os parsers
      gcc
      gnumake

      # Essenciais para o Clipboard funcionar no Wayland
      wl-clipboard

      # Essenciais para o Mason conseguir baixar e rodar alguns LSPs
      unzip
      wget
      nodejs_22
      cargo

      # Necessário para o script de inicialização do jdtls via Mason
      python3
    ];
  };

  home.file.".config/nvim".source = ./nvim;
}
