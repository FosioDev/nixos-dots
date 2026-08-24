{
  fileSystems = {
    "/mnt/backups" = {
      device = "/dev/disk/by-uuid/55287544-ce9f-4c93-a2f6-a63b69623fe1";
      fsType = "ext4";
      options = [ "nofail" "noatime" "x-systemd.device-timeout=1s" ];
    };
  };
}
