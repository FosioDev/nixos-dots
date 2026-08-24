{
  imports = [
    /etc/nixos/hardware-configuration.nix
    ./packages.nix
    # ./inputs.nix
    # ./symlinks.nix

    ./hardware/gpu/amd.nix
    # ./hardware/gpu/intel.nix
    # ./hardware/gpu/nvidia.nix

    # ./hardware/filesystems.nix
    # ./hardware/hibernate.nix
    ./hardware/virtualisation.nix
    ./hardware/network.nix
    ./hardware/sound/sound.nix
    # ./hardware/vr.nix

    ./software/mpv/mpv.nix
    ./software/ranger/ranger.nix
    ./software/starship/starship.nix
    ./software/mangohud.nix
    ./software/zsh.nix

    ./themes/themes.nix

    ./wm/rofi/rofi.nix
    ./wm/dunst.nix
    ./wm/sway.nix
    ./wm/waybar.nix
  ];
}
