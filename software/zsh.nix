{ pkgs, config, ... }: {
  environment.systemPackages = [ pkgs.zsh-you-should-use ];

  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  # Сейчас почти всё можно без home-manager сделать
  hm.programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
      strategy = [
        "history" # Chooses the most recent match from history
        "completion" # Chooses a suggestion based on what tab-completion would suggest
      ];
    };
    syntaxHighlighting.enable = true;

    # Замена sddm, запускает sway после логина в tty1
    profileExtra = ''
      [ "$(tty)" = "/dev/tty1" ] && exec sway
    '';

    # Плюс это https://github.com/ohmyzsh/ohmyzsh/wiki/Cheatsheet
    shellAliases = let
      flakeDir = "~/nixos-dots";
    in {
      rbs = "sudo nixos-rebuild switch --impure --flake ${flakeDir}"; # Применить новый конфиг сразу
      rbb = "sudo nixos-rebuild boot --impure --flake ${flakeDir}"; # Применить новый конфиг после ребута пк

      # Я не помню что это значит, не использую
      # upg = "sudo nixos-rebuild switch --impure --upgrade --flake ${flakeDir}";

      # Обновить все flake inputs до последних версий
      # Если после upd дописать название инпута из flake.nix, то обновится только указанный инпут
      # Например `upd nixpkgs2` для обновления unstable репы
      upd = "sudo nix flake update --flake ${flakeDir}";

      # Garbage collector. Удалить все не используемые пакеты (например после обновы)
      grb = "sudo nix-collect-garbage -d";

      pkgs = "nvim ${flakeDir}/nixos/packages.nix";

      vim = "nvim";
      vi = "nvim";
      v = "nvim";
      
      k = "kubectl";
      t = "timer";
      r = "ranger --choosedir=/tmp/choosedir && cd \"$(cat /tmp/choosedir)\"";
      g = "gitui";
      f = "fastfetch";
      b = "bat --color=always -p --pager='-r'"; # Веди себя как cat, но с цветами
      # l = "ls -lah";

      yt = "yt-dlp --cookies /mnt/backups/Media/yt-dlp/cookies.firefox-private.txt";
      yt-dir = "cd /mnt/backups/Media/yt-dlp";
      yt-music = "yt-dlp --config-locations music.conf | sed '/has already been recorded in the archive/d'";
      yt-video = "yt-dlp --config-locations video.conf | sed '/has already been recorded in the archive/d'";
      yt-jp = "yt-dlp --config-locations music-jp.conf | sed '/has already been recorded in the archive/d'";
      qb = "cd /mnt/backups/Media/Music/Qobuz/qdl";
      html = "python3 /mnt/backups/html-library/generate_gallery.py --path";
    };

    history = {
      ignoreAllDups = true; # Удалять дубликаты из истории
      ignoreSpace = true; # Не сохранять команду в истории, если перед ней стоит пробел
    };

    # Environment variables that will be set for zsh session.
    # sessionVariables = {
    # };

    # Extra commands that should be added to .zshrc
    initContent = ''
      source ${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use/you-should-use.plugin.zsh
      unset -f d
    '';

    historySubstringSearch = {
      enable = true; # Чтоб вверх/вниз учитывал уже написанную команду
      searchUpKey = [
        "^[[A"
        "$terminfo[kcuu1]"
      ];
      searchDownKey = [
        "^[[B"
        "$terminfo[kcud1]"
      ];
    };

    oh-my-zsh = { # https://github.com/ohmyzsh/ohmyzsh
      enable = true;
      plugins = [ # Комментирую то, в надобности чего не уверен, но показалось интересным. Можно удалить
        "aliases" # "als" в терминале покажет все алиасы. Можно добавить слово для фильтрации
        "bgnotify" # Оповещения для долгих команд. Make sure you have "notify-send" or "kdialog" installed
        "colored-man-pages" # Adds colors to man pages
        "extract" # Одна команда на все архивы: "x *.zip"
        "fzf" # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/fzf
        "safe-paste" # Preventing any code from running while pasting, so you have a chance to review what was pasted
        "ssh-agent" # Автостарт ssh-agent. Хз надо ли настраивать и если да, то как
        "timer" # Показывает время выполнения команды
        "universalarchive" # Run "ua <format> <files>": "ua zip ./"
      ];
    };
  };
}
