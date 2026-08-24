# Настройка гибернации в файл подкачки

# Проверить установлен ли сейчас resume: cat /sys/power/resume
# Если 0:0, то ничего не указано

# Узнать uuid файла подкачки:
# lsblk `df /swapfile | awk '/^\/dev/ {print $1}'` -no UUID

# Узнать offset файла подкачки:
# sudo filefrag -v /swapfile | awk '$1=="0:" {print substr($4, 1, length($4)-2)}'

{
  swapDevices = [ {
    device = "/swapfile";
    size = 48*1024; # В мегабайтах
  } ];

  boot = {
    resumeDevice = "/dev/disk/by-uuid/fda4276f-7867-4f87-856c-3683b532ac33";
    kernelParams = [ "resume_offset=115525632" ];
  };

  boot.kernel.sysctl = {
    # Частота использования подкачки, от 0 до 100, в стоке 60
    # Низкое значение заставляет ядро избегать подкачки
    # cat /proc/sys/vm/swappiness
    "vm.swappiness" = 20;
  };
}

