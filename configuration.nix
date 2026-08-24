{ pkgs, username, state, lib, ... }: {

  imports = [
    # Alias. Использовать через `config.hm.параметр`
    (lib.mkAliasOptionModule [ "hm" ] [ "home-manager" "users" username ])

    ./bundle.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  time.timeZone = "Europe/Moscow";

  i18n = let
    extraLocale = "ru_RU.UTF-8"; # Дата, временя, адреса и тд
  in {
    defaultLocale = "en_US.UTF-8"; # Язык системы

    extraLocaleSettings = {
      LC_ADDRESS = extraLocale;
      LC_IDENTIFICATION = extraLocale;
      LC_MEASUREMENT = extraLocale;
      LC_MONETARY = extraLocale;
      LC_NAME = extraLocale;
      LC_NUMERIC = extraLocale;
      LC_PAPER = extraLocale;
      LC_TELEPHONE = extraLocale;
      LC_TIME = extraLocale;
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "networkmanager" "wheel" "input" "libvirtd" "storage" "docker" "video" "render" ];
  };

  boot.kernelPackages = pkgs.linuxPackages_latest; # Ласт ядро линуха

  hm.programs.home-manager.enable = true;
  hm.home = {
    username = username;
    homeDirectory = "/home/${username}";

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      BROWSER = "librewolf";
      TERMINAL = "alacritty";
      TERM = "alacritty";
      PATH = "$PATH:/home/${username}/go/bin";
    };

    stateVersion = state; # Don't change it
  };

  system.stateVersion = state; # Don't change it
}
