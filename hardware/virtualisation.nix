{ pkgs, inputs, ... }: {
  environment.systemPackages = [
    inputs.uniclip.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  virtualisation = {
    waydroid.enable = true;

    docker = {
      enable = true;
      rootless.enable = true;
    };

    libvirtd = {
      enable = true;
      qemu.package = pkgs.qemu_full;
      qemu.vhostUserPackages = [ pkgs.virtiofsd ];
    };

    spiceUSBRedirection.enable = true;
  };

  # Network autostart `virsh net-autostart default`
  # https://nixos.wiki/wiki/Virt-manager
  programs.virt-manager.enable = true;
}
