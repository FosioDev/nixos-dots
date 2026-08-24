# Много готовых дизайнов для rofi https://github.com/adi1090x/rofi
# Там разделены launchers и applets. Я не сразу понял в чём разница
# Launchers просто запускает приложение и ничего больше
# Applets это кнопка, которой задаёшь своё имя и скрипт, который будет выполнен при нажатии
# Через applets можно запускать скрипты, проги от рута или отображать информацию по типу заряда акума
# Описание и генератор стилей https://comfoxx.github.io/rofi-old-generator/old.html
# Полезная инфа https://wiki.archlinux.org/title/Rofi
# Готовые скрипты https://github.com/davatorium/rofi/wiki/User-scripts

{ pkgs, config, ... }: {
  environment.systemPackages = with pkgs; [ libqalculate ]; # Калькулятор для rofi

  hm.programs.rofi = { # https://github.com/davatorium/rofi
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
      rofi-power-menu # https://github.com/jluttine/rofi-power-menu
    ];
  };


  # В теории размеры в пикселях можно оставить под fhd монитор
  # Wayland Scale 2 сделает их под 4к моник
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
