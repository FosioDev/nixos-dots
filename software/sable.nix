{ pkgs, lib, ... }:

let
  sable = pkgs.stdenv.mkDerivation rec {
    pname = "sable";
    version = "2.1.4";

    src = pkgs.fetchurl {
      url = "https://git.sable.moe/SableClient/sable-next/releases/download/v${version}/sable-electron-${version}-x64.tar.gz";
      hash = "sha256-Xzdi3fcpKVh4H0hLrfQzlHYT6vLul1yIUPezIytrJC0=";
    };

    nativeBuildInputs = with pkgs; [
      autoPatchelfHook
      makeWrapper
      copyDesktopItems
    ];

    buildInputs = with pkgs; [
      # Аудио (нужно для venmic-x64.node)
      pipewire
      libpulseaudio
      alsa-lib

      # Основные Electron-зависимости
      glib
      nss
      nspr
      atk
      at-spi2-atk
      cups
      dbus
      libdrm
      gtk3
      pango
      cairo
      expat
      libxkbcommon
      mesa
      libgbm
      libGL
      libglvnd
      vulkan-loader
      wayland

      # X11
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
      libxshmfence

      # udev
      (lib.getLib systemd)
    ];

    desktopItems = [
      (pkgs.makeDesktopItem {
        name = "sable";
        exec = "sable %U";
        icon = "sable";
        desktopName = "Sable";
        genericName = "Matrix Client";
        categories = [ "Network" "Chat" "InstantMessaging" ];
        comment = "Matrix client";
        mimeTypes = [
          "x-scheme-handler/matrix"
          "x-scheme-handler/sable"
        ];
      })
    ];

    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/opt/sable $out/bin
      cp -r ./* $out/opt/sable/

      install -D -m 644 resources/dist/icons/logo.svg $out/share/icons/hicolor/scalable/apps/sable.svg
      install -D -m 644 resources/dist/icons/logo-512x512.png $out/share/icons/hicolor/512x512/apps/sable.png

      makeWrapper $out/opt/sable/sable $out/bin/sable \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
        --prefix PATH : "${lib.makeBinPath [ pkgs.desktop-file-utils ]}"

      runHook postInstall
    '';

    meta = with lib; {
      description = "Sable Matrix Client";
      homepage = "https://git.sable.moe/SableClient/sable-next";
      license = licenses.agpl3Plus;
      platforms = [ "x86_64-linux" ];
      mainProgram = "sable";
    };
  };
in
{
  environment.systemPackages = [ sable ];

  # Назначаем Sable обработчиком ссылок matrix:// и sable:// на уровне системы
  xdg.mime.defaultApplications = {
    "x-scheme-handler/matrix" = "sable.desktop";
    "x-scheme-handler/sable" = "sable.desktop";
  };
}
