{ pkgs, pkgs2, spkgs, pkgsld, strawberry, inputs, ... }: {

  # Кеш, чтоб не компилить некоторый софт
  # Сам софт будет в inputs.nix
  nix.settings = {
    substituters = [
      "https://cache.forall.systems"
      "https://nix-gaming.cachix.org"
    ];
    trusted-public-keys = [
      # https://github.com/mrshmllow/affinity-nix
      "cache.forall.systems:5PmD7QO4MSF8YgyRZtkSGXRDo96H3bybIf2SsQh8ScI="

      # https://github.com/fufexan/nix-gaming
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    ];
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-serif
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    noto-fonts-monochrome-emoji
    nerd-fonts.jetbrains-mono
    nerd-fonts.noto
    nerd-fonts.caskaydia-mono
    carlito
    terminus_font
    inconsolata
    font-awesome
    liberation_ttf
    dejavu_fonts
    cantarell-fonts
    unifont
    unifont_upper
  ];

  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
    };
    efi.canTouchEfiVariables = true;
  };

  # Всплывающее меню для ввода пароля
  security.polkit.enable = true;
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
    };
  };

  services = {
    gvfs.enable = true; # Mount, trash, and other functionalities for file manager
    flatpak.enable = true;
    # languagetool = {
    #   enable = true;
    #   port = 8090;
    # };
  };

  programs = {
    nix-ld = {
      enable = true;
      libraries = with pkgsld; [
        # For Throne 1.2.1
        kdePackages.qtbase
        kdePackages.qttools
        kdePackages.qtwayland
        kdePackages.qtsvg
        kdePackages.qtimageformats
        util-linux
        zlib
        zstd
        mesa
        libGL
        libglvnd
        libxkbcommon
        freetype
        fontconfig
        libx11
        libxext
        libxrandr
        libxrender
        libxcursor
        libxxf86vm
        libxi
        libxcb
        libxfixes
        libxcb-util
        libxcb-keysyms
        libxcb-wm
        libxcb-image
        libxcb-render-util
        xcb-util-cursor
        glib
        dbus
        krb5
      ];
    };

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-qt;
    };

    appimage = {
      enable = true;
      binfmt = true;
      package = pkgs.appimage-run.override { # Зависимости для нужных мне приложений
        extraPkgs = pkgs: with pkgs; [ libpng libpng12 libepoxy pcre2 double-conversion ];
      };
    };

    gamemode.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
  };

  hardware = {
    opentabletdriver.enable = true;
    keyboard.qmk.enable = true;
  };

  hm.programs = {
    alacritty = {
      enable = true;
      settings.window.padding = { x = 5; y = 5; };
    };
    kitty = { # Кривой ssh, но быстрый протокол рендера видео
      enable = true;

      shellIntegration = {
        enableBashIntegration = true;
        enableZshIntegration = true;
      };

      settings = {
        window_padding_width = 5;
      };
    };
  };
  services.tumbler.enable = true; # XFCE Thumbnails
  programs = {
    xfconf.enable = true; # Thunar configs
    thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-media-tags-plugin
        thunar-archive-plugin
        thunar-volman
      ];
    };
  };

  environment.systemPackages = with pkgs; [

    #########################################
    ## Выше есть настройки для этого софта ##
    #########################################

    alacritty ueberzugpp
    kitty
    catfish xfce4-exo # thunar

    #############
    ## Wayland ##
    #############

    wl-clipboard
    cliphist
    wtype
    pass-wayland
    wlr-randr
    wev
    grim
    slurp
    satty
    wayfreeze
    qt5.qtwayland
    qt6.qtwayland
    # sdl12-compat # sdl1 не работает с wayland, это фикс мб

    ##########
    ## Code ##
    ##########

    # Минималистичный агент для программирования
    # В nix-ld поместить нужную версию pi.openssl нельзя, тк там старые версии либ, которые с ним конфликтуют
    # (stdenv.mkDerivation {
    #   name = "pi-fixed";
    #   nativeBuildInputs = [ patchelf makeWrapper ];
    #   unpackPhase = "true";
    #   installPhase = ''
    #     mkdir -p $out/bin
    #
    #     # Создаем пропатченную ноду
    #     cp ${pi.nodejs}/bin/node $out/bin/.pi-node-wrapped
    #     chmod +w $out/bin/.pi-node-wrapped
    #
    #     old_rpath=$(patchelf --print-rpath $out/bin/.pi-node-wrapped)
    #     new_libs="${pi.openssl.out}/lib:${pi.stdenv.cc.cc}/lib"
    #     new_rpath="$new_libs:$old_rpath"
    #
    #     interpreter=$(cat ${pi.stdenv.cc}/nix-support/dynamic-linker)
    #
    #     patchelf --set-interpreter "$interpreter" \
    #              --set-rpath "$new_rpath" \
    #              --force-rpath \
    #              $out/bin/.pi-node-wrapped
    #
    #     # Копируем оригиналиный shell-скрипт pi
    #     cp ${pi.pi-coding-agent}/bin/pi $out/bin/.pi-script-raw
    #     chmod +w $out/bin/.pi-script-raw
    #
    #     # Подменяем путь к ноде внутри этого скрипта
    #     # Мы ищем оригинальную ноду и меняем её на нашу пропатченную
    #     sed -i "s|${pi.nodejs}/bin/node|$out/bin/.pi-node-wrapped|g" $out/bin/.pi-script-raw
    #
    #     # Создаем финальную обертку, которая чистит переменные nix-ld и запускает наш измененный скрипт
    #     makeWrapper $out/bin/.pi-script-raw $out/bin/pi \
    #       --unset LD_LIBRARY_PATH \
    #       --unset NIX_LD_LIBRARY_PATH \
    #       --unset NIX_LD \
    #       --set PI_OFFLINE 1 # Отключает телеметрию, проверку пакетов и обновлений в pi
    #   '';
    # })

    # Инструмент для работы с контекстом кода CodeMapper https://github.com/elpapi42/codemapper-fork
    # (pkgs2.rustPlatform.buildRustPackage {
    #   pname = "codemapper";
    #   version = "unstable-2026";
    #
    #   src = fetchFromGitHub {
    #     owner = "elpapi42";
    #     repo = "codemapper-fork";
    #     rev = "main"; # Или конкретный коммит, если нужна фиксация версии
    #
    #     hash = "sha256-rNnrJOxgC51vi1CQ+z2hrnklBn7q4mVISq3oZ1/ebYk=";
    #   };
    #
    #   # Отключаем тесты, так как тест 'test_is_git_repo' требует папки .git,
    #   # которая отсутствует в изолированной среде сборки Nix.
    #   doCheck = false;
    #
    #   cargoHash = "sha256-LrvLmRto9NhGrGRepV7UOFcqce2+i86MNIQ5agB9mYg=";
    # })

    vscode-fhs
    spkgs.neovim
    tree-sitter
    ripgrep
    fd

    nixd
    gnumake
    # spkgs.hugo # Надо 24.11 или 24.05 для моего блога
    yaml-language-server
    taplo

    python3
    # python3Packages.pip

    go
    gopls
    delve
    golangci-lint

    protobuf
    protoc-gen-go
    protoc-gen-go-grpc

    lua5_1
    luajit
    luajitPackages.luarocks
    lua-language-server

    bash-language-server
    shellcheck
    shfmt

    sqlite
    dbeaver-bin

    nodejs_24
    emmet-language-server
    vscode-langservers-extracted
    typescript-language-server
    tailwindcss-language-server
    svelte-language-server
    tailwindcss_4

    godot
    # gdtoolkit_4
    # ldtk

    # k3d
    # k3s
    # k9s
    # kubectl
    # kubernetes-helm


    ##############
    ## Terminal ##
    ##############

    zip unzip unrar gnutar p7zip bzip2
    openssl wget curl git tree
    xdg-utils usbutils exiftool
    f2fs-tools exfat lm_sensors
    pwgen jq ffmpeg_7 imagemagick
    gnugrep rsync fastfetch bat
    btop fzf killall libxml2
    miller svt-av1 gawk tokei
    gitui fclones zellij timer
    inetutils playerctl libnotify
    brightnessctl
    pkgs2.yt-dlp
    pkgs2.gallery-dl

    android-tools
    scrcpy # Стримить мобилу/камеру на пк по usb


    ###########
    ## Files ##
    ###########

    ffmpegthumbnailer
    gnome-epub-thumbnailer
    # nufraw-thumbnailer # Thumbnailer for .raw images from digital cameras
    # mcomix # Thumbnailer for .crb comicbook archives (требует mupdf, который крашит систему)
    # f3d # Thumbnailer for 3D files, including glTF, stl, step, ply, obj, fbx. (требует openturns, который крашит систему)
    openscad # 3D model previews (stl, off, dxf, scad, csg). Этот именно для ranger

    kdePackages.kimageformats # Image format plugins for Qt
    spkgs.libsForQt5.kimageformats
    kdePackages.qtimageformats # Image formats: TIFF, MNG, TGA, WBMP
    spkgs.libsForQt5.qt5.qtimageformats
    kdePackages.qtsvg
    kdePackages.karchive # Plugin for Krita and OpenRaster images
    webp-pixbuf-loader
    gdk-pixbuf.dev
    libwebp libavif libheif
    libjxl jxrlib libraw librsvg
    libgsf # .odf support
    poppler
    freetype
    imath
    openexr


    ###########
    ## Games ##
    ###########

    # lutris # Запускать .exe игры. Не всё через `wine game.exe` работает на nixos нормально
    # heroic
    # sidequest # Ставить APK файлы на Oculus Quest 2
    # bs-manager # Удобно ставить моды и менять версии Beat Saber
    prismlauncher

    pkgs2.protonup-qt
    # steam-run # Запуск бинарей в окружении, похожем на steam runtime
    wine-wayland
    winetricks
    # protontricks

    dxvk # Direct3D 8/9/10/11
    vkd3d # Direct3D 12
    vkd3d-proton


    ###########
    ## Icons ##
    ###########

    adwaita-icon-theme
    spkgs.libsForQt5.breeze-icons # qt5
    kdePackages.breeze-icons # qt6
    papirus-icon-theme
    material-icons
    gruvbox-plus-icons


    ############
    ## Random ##
    ############

    pkgs2.discord
    pkgs2.vesktop
    pkgs2.telegram-desktop


    librewolf
    firefox
    chromium
    floorp-bin


    evince # Смотреть документы (так же превью PDF файлов для Thunar) (не читает FB2)
    # papers # Современная замена для evince под GTK4. Оба от gnome
    libreoffice
    hunspell # Проверка орфографии для libreoffice
    hunspellDicts.ru_RU # Словарь
    hunspellDicts.en_US # Словарь
    calibre # Работа с ebook. Иногда даёт thumbnail в файловом менеджере
    # drawio # Diagrams. Вроде даёт thumbnail в ranger
    spkgs.xournalpp


    # eloquent # GUI для LanguageTool
    obsidian
    anki
    pomodoro-gtk
    spkgs.planify


    strawberry.strawberry
    obs-studio
    picard # Массовый редактор метаданных музыки
    mousai
    spek # Спектрограмма аудио
    qview # Умеет в анимированный webp и avif, но не умеет в apng
    krita
    blender
    upscayl # Open Source AI Image Upscaler
    # davinci-resolve


    file-roller
    qbittorrent
    thunderbird


    qmk vial
    # gucharmap # Проверка шрифтов. Какой шрифт какие символы отображает
    vrrtest # Тест на тиринг. Поставил 161 фпс на 160 герц монике и увидел прикол
    vulkan-tools
    libsecret
  ];
}
