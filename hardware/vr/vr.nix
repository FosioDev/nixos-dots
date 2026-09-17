# https://vronlinux.org/
{ pkgs, ... }: let
  xr-video-player = pkgs.callPackage ./xr-video-player.nix { };
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

