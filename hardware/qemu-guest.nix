{
  services = {
    openssh.enable = true;
    qemuGuest.enable = true; # Fix resolution
    # spice-vdagentd.enable = true; # Не работает на wayland
  };
}
