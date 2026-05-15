{ config, pkgs, ... }:

{
  programs.mpv = {
    enable = true;

    scripts = with pkgs.mpvScripts; [
      mpris            # Permite controlar o MPV pelos botões de mídia do teclado
      sponsorblock     # Pula segmentos pagos em vídeos do YouTube
      quality-menu     # Cria um menu para trocar a resolução de vídeos do YT (usando yt-dlp)
      thumbfast        # Gera miniaturas ao passar o mouse na barra de progresso
      thumbnail        # Exibe a miniatura gerada pelo thumbfast
    ];

    # Configurações nativas do mpv.conf
    config = {
      profile = "gpu-hq";         # Usa renderização de alta qualidade na placa de vídeo
      hwdec = "auto";             # Habilita decodificação por hardware (economia de bateria)
      keep-open = "yes";          # Não fecha o player quando o vídeo acaba
      ytdl-format = "bestvideo+bestaudio/best"; # Padrão de qualidade para links online
      save-position-on-quit = "yes"; # Lembra onde você parou de assistir
      osc = "no";
    };

    # Atalhos e integrações no input.conf
    bindings = {
      UP    = "add volume 5";
      DOWN  = "add volume -5";
      WHEEL_UP   = "add volume 5";
      WHEEL_DOWN = "add volume -5";
      "F"     = "script-binding quality_menu/video_formats_toggle"; # Abre o menu de qualidade
    };
  };

  # Garante que o yt-dlp seja instalado junto para que o MPV consiga tocar links online
  home.packages = [ pkgs.yt-dlp ];

  # --- APLICATIVOS PADRÃO (MIME Types) ---
  xdg.mimeApps = {
    defaultApplications = {
      # Vídeo e Áudio abrem com o mpv
      "video/*"  = [ "mpv.desktop" ];
      "audio/*" = [ "mpv.desktop" ];
    };
  };
}
