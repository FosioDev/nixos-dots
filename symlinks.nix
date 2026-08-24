# `lib.file.mkOutOfStoreSymlink` делает симлинк не read only через nix store
# В теории должно быть нормальным для часто изменяющихся файлов

{ config, lib, ... }: let
  dir = "backups";
in {
  hm.home.file = { # В .config этим нельзя кидать
    "${dir}".source = lib.file.mkOutOfStoreSymlink "/mnt/${dir}";

    # Secrets
    ".password-store".source = lib.file.mkOutOfStoreSymlink "/mnt/${dir}/Backups/.password-store";
    ".ssh".source = lib.file.mkOutOfStoreSymlink "/mnt/${dir}/Backups/.ssh";

    # Browsers. Мб сделать .force, чтоб удалить сток. А мб руками удалить сток перед этим
    ".mozilla".source = lib.file.mkOutOfStoreSymlink "/mnt/${dir}/Backups/Apps/.mozilla";
    ".librewolf".source = lib.file.mkOutOfStoreSymlink "/mnt/${dir}/Backups/Apps/.librewolf";

    "Downloads/Telegram Desktop".source = lib.file.mkOutOfStoreSymlink "/mnt/${dir}/Telegram Desktop";
  };

  hm.xdg.configFile = { # Это для каталога .config
    "qobuz-dl".source = lib.file.mkOutOfStoreSymlink "/mnt/${dir}/Media/Music/Qobuz/.config/qobuz-dl";
    # "chromium".source = lib.file.mkOutOfStoreSymlink "/mnt/${dir}/Backups/Apps/chromium";
  };
}


