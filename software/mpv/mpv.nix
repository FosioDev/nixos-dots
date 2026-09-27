{ mpv-ffmpeg, config, ... }: {
  environment.systemPackages = with mpv-ffmpeg; [ mpv ];

  hm.xdg.configFile = {
    "mpv/mpv.conf".source = ./mpv.conf;
    "mpv/input.conf".source = ./input.conf;
    "mpv/scripts".source = ./scripts;
    "mpv/script-opts".source = ./script-opts;
    "mpv/fonts".source = ./fonts;
  };
}

