{ pkgs, ... }: {
  virtualisation = {
    waydroid.enable = true;

    docker = {
      enable = true;
      rootless.enable = true;
    };

    libvirtd = {
      enable = true;
      qemu.package = pkgs.qemu_full;
    };

    spiceUSBRedirection.enable = true;
  };

  # Network autostart `virsh net-autostart default`
  # https://nixos.wiki/wiki/Virt-manager
  programs.virt-manager.enable = true;

  #################################################
  ## Это надо включить на виртуалке, не на хосте ##
  #################################################

  # services = {
  #   openssh.enable = true;
  #   spice-vdagentd.enable = true; # Clipboard sharing
  #   qemuGuest.enable = true; # Fix resolution
  #   # Ниже я не включаю
  #   # spice-webdavd.enable = true; # VirtFS alternative for directory sharing
  # };
}
