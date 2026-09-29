{ pkgs, lib, ... }:
let
  harmony = pkgs.stdenv.mkDerivation rec {
    pname = "harmony";
    version = "0.6.0";

    src = pkgs.fetchurl {
      url = "https://codeberg.org/catcraft/harmony/releases/download/v${version}/harmony-linux-x64-v${version}.tar.xz";
      hash = "sha256-RHMIn808jSfQJcQ1RNWexN855HnPYRH5/FvXOogFfJM=";
    };

    nativeBuildInputs = with pkgs; [
      autoPatchelfHook
      makeWrapper
      copyDesktopItems
    ];

    buildInputs = with pkgs; [
      # Графика и мультимедиа
      libglvnd
      alsa-lib
      at-spi2-atk
      atk
      cairo
      cups
      dbus
      expat
      glib
      gtk3
      libdrm
      libGL
      libgbm
      libxkbcommon
      mesa
      nspr
      nss
      pango
      (lib.getLib systemd)
      vulkan-loader
      wayland

      # X11 библиотеки
      libx11
      libxcomposite
      libxcursor
      libxdamage
      libxext
      libxfixes
      libxi
      libxrandr
      libxrender
      libxtst
      libxcb
    ];

    # Создает ярлык в меню приложений (Rofi, Wofi, GNOME и т.д.)
    desktopItems = [
      (pkgs.makeDesktopItem {
        name = "harmony";
        exec = "harmony %U";
        icon = "harmony";
        desktopName = "Harmony";
        genericName = "Matrix Client";
        categories = [ "Network" "Chat" "InstantMessaging" ];
      })
    ];

    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/opt/harmony $out/bin
      cp -r ./* $out/opt/harmony/

      # Создаем симлинк-обертку в системный PATH
      # Пробрасываем библиотеки драйверов EGL/GL в рантайм
      makeWrapper $out/opt/harmony/harmony $out/bin/harmony \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ pkgs.libglvnd pkgs.libGL ]}"

      runHook postInstall
    '';

    meta = with lib; {
      description = "Harmony Matrix Client";
      homepage = "https://codeberg.org/catcraft/harmony";
      license = licenses.agpl3Only;
      platforms = [ "x86_64-linux" ];
      mainProgram = "harmony";
    };
  };
in
{
  environment.systemPackages = [
    harmony
  ];
}
