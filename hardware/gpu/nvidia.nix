# https://nixos.wiki/wiki/Nvidia
# Для архитектуры Blackwell и новее. Старые архитектуры иначе настраивать надо
{ pkgs, config, ... }: {
  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware = {
    # Enable OpenGL
    graphics = {
      enable = true;
    };

    nvidia = {
      open = true; # Открытый драйвер нвидиа. Обязательно для blackwell+ архитектур
      modesetting.enable = true; # KMS (Kernel Mode Setting). Для корректной работы Wayland и PRIME
      powerManagement.enable = true; # Позволяет NVIDIA засыпать, когда не используется
      powerManagement.finegrained = true; # Более тонкое управление питанием (работает на Turing+)
      nvidiaSettings = false;  # Не ставить nvidia-settings (графическая утилита).
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    nvidia-container-toolkit = {
	    enable = true; # Для работы карт nvidia в контейнерах
	    package = pkgs.nvidia-container-toolkit;
	  };
  };
}
