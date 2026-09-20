{ config, lib, ... }: {
  # Если курсор перевёрнут
  # environment.sessionVariables = {
  #   WLR_NO_HARDWARE_CURSORS = "1";
  # };

  # Выключить смену языка биндом на виртуалке
  # Нажатие Caps Lock ничего не делает, Shift + Caps Lock включает реальный Caps Lock
  # Если надо менять язык на виртуалке обычным способом, то закомментируй эту настройку
  hm.wayland.windowManager.sway.config.input."type:keyboard".xkb_options = lib.mkForce "caps:shift_caps_cancel";

  services = {
    openssh.enable = true;
    qemuGuest.enable = true; # Fix resolution
    # spice-vdagentd.enable = true; # Не работает на wayland
  };
}
