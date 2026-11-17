{
  imports = [
    /etc/nixos/hardware-configuration.nix
    ./packages.nix
    # ./inputs.nix

    ./hardware/gpu/amd.nix
    # ./hardware/gpu/intel.nix
    # ./hardware/gpu/nvidia.nix

    # WARN: Удали каталоги браузеров перед созданием симлинка
    # И замаунти диски нужные
    # ./symlinks.nix

    # ./hardware/filesystems.nix
    # ./hardware/hibernate.nix
    ./hardware/virtualisation.nix
    ./hardware/network.nix
    ./hardware/sound.nix
    # ./hardware/qemu-guest.nix
    # ./hardware/vr.nix

    ./software/mpv/mpv.nix
    ./software/ranger/ranger.nix
    ./software/rofi/rofi.nix
    ./software/sway/sway.nix
    ./software/waybar/waybar.nix
    ./software/zsh/zsh.nix
    ./software/dunst.nix
    ./software/sable.nix
    # ./software/mangohud.nix
    # ./software/pi.nix

    ./themes/themes.nix
  ];
}
