# `lib.file.mkOutOfStoreSymlink` делает симлинк не read only через nix store
# В теории должно быть нормальным для часто изменяющихся файлов

{ config, lib, ... }: let
  dir = "backups";
in {
  hm.home.file = { # В .config этим нельзя кидать
    "${dir}".source = config.hm.lib.file.mkOutOfStoreSymlink "/mnt/${dir}";

    ".password-store".source = config.hm.lib.file.mkOutOfStoreSymlink "/mnt/${dir}/Backups/.password-store";
    ".ssh".source = config.hm.lib.file.mkOutOfStoreSymlink "/mnt/${dir}/Backups/.ssh";

    "Downloads/Telegram Desktop".source = config.hm.lib.file.mkOutOfStoreSymlink "/mnt/${dir}/Telegram Desktop";
  };

  hm.xdg.configFile = { # Это для каталога .config
    "qobuz-dl".source = config.hm.lib.file.mkOutOfStoreSymlink "/mnt/${dir}/Media/Music/Qobuz/.config/qobuz-dl";
    "chromium".source = config.hm.lib.file.mkOutOfStoreSymlink "/mnt/${dir}/Backups/Apps/chromium";
    "mozilla".source = config.hm.lib.file.mkOutOfStoreSymlink "/mnt/${dir}/Backups/Apps/.mozilla";
    "librewolf/librewolf".source = config.hm.lib.file.mkOutOfStoreSymlink "/mnt/${dir}/Backups/Apps/.librewolf";
    "Throne".source = config.hm.lib.file.mkOutOfStoreSymlink "/mnt/${dir}/Backups/Apps/Throne";
  };
}


