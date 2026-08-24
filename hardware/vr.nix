# Beat Saber является OpenXR игрой, что не поддерживается Alvr из коробки
# Возможно на X11 это можно исправить простой настройкой в SteamVR
# Но на Wayland мне приходилось качать разом весь этот софт на Arch
# Поэтому сразу поставил всё что надо и не пробовал найти необходимый минимум
# Мб пригодится поставить opencomposite для трансляции OpenVR в OpenXR

{
  services = {

    # Open source XR runtime
    monado = {
      enable = true;
    };

    # An OpenXR streaming application to a standalone headset
    # wivrn = {
    #   enable = true;
    #   openFirewall = true;
    # };
    
  };

  programs = {

    # Stream VR games from your PC to your headset via Wi-Fi
    alvr = {
      enable = true;
      openFirewall = true;
    };

    # UI for Monado, the open source OpenXR runtime
    # envision = {
    #   enable = true;
    #   openFirewall = true;
    # };

  };
}

