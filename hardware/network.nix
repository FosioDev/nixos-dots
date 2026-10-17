{ pkgs, throne, ... }: {
  environment.systemPackages = with pkgs; [
    networkmanagerapplet # Tray for network manager
  ];

  hardware.bluetooth.enable = true;
  services.blueman.enable = true; # Tray for bluetooth
  networking = {
    networkmanager.enable = true;
    enableIPv6 = false;
    firewall.enable = false;
    # wireless.enable = true;
  };

  # services.v2raya = {
  #   enable = true;
  #   cliPackage = pkgs2.xray;
  # };

  programs = {
    # Добавить это github.com/kartavkun/zapret-discord-youtube
    throne = {
      # Оборачиваем пакет, добавляя флаг запуска
      package = (pkgs.symlinkJoin {
        name = "throne-wayland";
        paths = [ throne.throne ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/Throne \
            --add-flags "-platform wayland"
        '';
      }) // { inherit (throne.throne) passthru; }; # Пробрасываем passthru.core для tunMode
      enable = true;
      tunMode = {
        enable = true;
        setuid = true;
      };
    };
  };
}
