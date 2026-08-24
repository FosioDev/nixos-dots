{ pkgs, config, ... }: {
  environment.systemPackages = with pkgs; [ mpv ];

  hm.xdg.configFile = {
    "mpv/mpv.conf".source = ./mpv.conf;
    "mpv/input.conf".source = ./input.conf;
    "mpv/scripts".source = ./scripts;
    "mpv/script-opts".source = ./script-opts;
    "mpv/fonts".source = ./fonts;
  };
}

