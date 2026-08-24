{ pkgs, ... }: {
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
      enable = true;
      tunMode = {
        enable = true;
        setuid = true;
      };
    };
  };
}
