{ pkgs, config, lib, username, ... }: {

  imports = [
    ./colors.nix
  ];

  stylix = {
    enable = true;
    autoEnable = true;

    # Если хочешь генерить тему из обоев, то удали эту строку
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";

    # image = ./media/1.png; # Не работает
    # Вместо обоев можно сделать заливку фона одним цветом из темы
    # image = config.lib.stylix.pixel "base01";

    # “either”, “light”, “dark”
    polarity = "dark";

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 32; # default = 32
    };

    icons = {
      enable = true;
      dark = "Gruvbox-Plus-Dark";
      light = "Gruvbox-Plus-Light";
      package = pkgs.gruvbox-plus-icons;
      # Если часть иконок не работает, то офни сверху и включи снизу
      # dark = "Papirus-Dark";
      # light = "Papirus-Light";
      # package = pkgs.papirus-icon-theme;
    };

    fonts = {

      # С засечками
      serif = {
        package = pkgs.nerd-fonts.noto;
        name = "NotoSerif Nerd Font";
      };

      # Без засечек будет с засечками
      # Иначе Il| выглядят одинаково визуально
      # На monospace интерфесы ломаются, иначе бы его поставил везде
      sansSerif = config.stylix.fonts.serif;
      # sansSerif = {
      #   package = pkgs.nerd-fonts.noto;
      #   name = "NotoSans Nerd Font";
      # };

      # Ширина символов одинаковая
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMonoNL Nerd Font Mono";
      };

      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };

      sizes = {
      #   applications = 12;
        terminal = 15;
      #   desktop = 10;
      #   popups = config.stylix.fonts.sizes.desktop;
      };

    };
  };

  hm.home.file.".local/share/flatpak/overrides/global".text = ''
    [Context]
    filesystems=/nix/store:ro;/home/${username}/.themes/adw-gtk3:ro;

    [Environment]
    GTK_THEME=adw-gtk3
  '';

  stylix.targets = {
    chromium.enable = false;
  };
  hm.stylix.targets = {
    vscode.enable = false;
    firefox.enable = false;
    vencord.enable = false;
    vesktop.enable = false;
    nixcord.enable = false;
    btop.enable = false;
    yazi.enable = false;
    neovim.enable = false;
    gitui.enable = false;
    mpv.enable = false;
    obsidian.enable = false;
    zed.enable = false;
    waybar.enable = false;
    gtk.flatpakSupport.enable = false; # Крашит работу с flatpak, руками задал выше
  };

  hm.programs.zellij.enable = true;
  hm.programs.zellij.themes.stylix.themes = with config.lib.stylix.colors.withHashtag; {
    default = {
      ribbon_selected.background = lib.mkForce base0B;
      table_title.base = lib.mkForce base0B;
      frame_selected.base = lib.mkForce base0B;
    };
  };

  my.colors = with config.lib.stylix.colors.withHashtag; {
    base00 = base00;
    base01 = base01;
    base02 = base02;
    base03 = base03;
    base04 = base04;
    base05 = base05;
    base06 = base06;
    base07 = base07;
    base08 = base08;
    base09 = base09;
    base0A = base0A;
    base0B = base0B;
    base0C = base0C;
    base0D = base0D;
    base0E = base0E;
    base0F = base0F;
  };
}
