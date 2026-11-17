{ pkgs, config, ... }: {
  environment.systemPackages = with pkgs; [ libqalculate ];

  hm.programs.rofi = {
    enable = true;
    terminal = "${pkgs.alacritty}/bin/alacritty";
    location = "center";

    pass = { # https://github.com/carnager/rofi-pass
      enable = true;
      package = pkgs.rofi-pass-wayland;
      extraConfig = ''
        _rofi () {
          rofi -i -no-auto-select -theme ${config.hm.home.homeDirectory}/.config/rofi/launcher.rasi "$@"
        }
      '';
    };

    plugins = with pkgs; [
      rofi-calc # https://github.com/svenstaro/rofi-calc
    ];
  };

  # Power Menu zsh script
  nixpkgs.overlays = [
    (final: prev: {
      rofi-power-menu = prev.writeScriptBin "rofi-power-menu" (builtins.readFile ./rofi-power-menu.zsh);
    })
  ];

  hm.xdg.configFile = {
    "rofi/launcher.rasi".source = ./launcher.rasi;
    "rofi/power.rasi".source = ./power.rasi;
    "rofi/colors.rasi".text = ''
      * {
        background:     ${config.my.colors.base00};
        background-alt: ${config.my.colors.base01};
        foreground:     ${config.my.colors.base06};
        selected:       ${config.my.colors.base0D};
        active:         ${config.my.colors.base0B};
        urgent:         ${config.my.colors.base08};
      }
    '';
  };
}
