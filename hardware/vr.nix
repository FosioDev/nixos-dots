# https://vronlinux.org/
{ pkgs, lib, ... }: let
  xr-video-player = pkgs.stdenv.mkDerivation {
    pname = "xr-video-player";
    version = "idk-2026-01-19";

    src = pkgs.fetchFromGitea {
      domain = "codeberg.org";
      owner = "yoshino";
      repo = "xr-video-player";
      rev = "d3fb486f4615bd365b39e7ca4b855a612cca5612";
      hash = "sha256-3t2Ed1wWbe55ugR5O4QO4fmCI3muXlmozgX60ySydo0=";
    };

    nativeBuildInputs = with pkgs; [
      cmake
      pkg-config
    ];

    buildInputs = with pkgs; [
      openxr-loader
      mpv
      glm
      libepoxy
      glib
      SDL2
      wayland
      pipewire
      libdrm
    ];

    meta = with lib; {
      description = "VR video player for OpenXR and Wayland";
      homepage = "https://codeberg.org/yoshino/xr-video-player";
      license = licenses.gpl3Plus;
      platforms = platforms.linux;
      mainProgram = "xr-video-player";
    };
  };
in {
  environment.systemPackages = with pkgs; [
    xr-video-player
    # sidequest # Ставить APK файлы на Quest
    # bs-manager # Удобно ставить моды и менять версии Beat Saber
    # opencomposite # Чтоб OpenVR приложения работали
    xrizer # Современная замена opencomposite
    wayvr
  ];

  services = {
    wivrn = {
      enable = true;
      openFirewall = true;
    };

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}

