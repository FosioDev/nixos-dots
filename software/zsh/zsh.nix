{ pkgs, config, ... }: {
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  # Ctrl + R — Поиск по истории
  # Ctrl + T — Быстрая вставка пути к файлу прямо в команду
  # Alt + C — Интерактивный cd
  hm.programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

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

    shellAliases = let
      flakeDir = "~/nixos-dots";
    in {
      rbs = "sudo nixos-rebuild switch --impure --flake ${flakeDir}";
      rbb = "sudo nixos-rebuild boot --impure --flake ${flakeDir}";
      upd = "sudo nix flake update --flake ${flakeDir}"; # upd nixpkgs2
      grb = "sudo nix-collect-garbage -d";

      vim = "nvim";
      vi = "nvim";
      v = "nvim";
      k = "kubectl";
      t = "timer";
      r = "ranger --choosedir=/tmp/choosedir && cd \"$(cat /tmp/choosedir)\"";
      g = "gitui";
      f = "fastfetch";
      b = "bat --color=always -p --pager='-r'"; # Веди себя как cat, но с цветами

      ls = "ls --color=auto";
      l = "ls -lAh --color=auto";
      ll = "ls -lh --color=auto";
      md = "mkdir -p";
      grep = "grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,.venv,venv}";

      swaysleep = "swayidle -w timeout 5 'swaymsg \"output * dpms off\"' resume 'swaymsg \"output * dpms on\"; kill $PPID'";

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
      # Модуль zsh для работы со временем. Нужен в некоторых скриптах
      zmodload zsh/datetime

      # Замена colored-man-pages из Oh-My-Zsh:
      export LESS_TERMCAP_mb=$'\e[1;31m'      # Начало мигания (красный)
      export LESS_TERMCAP_md=$'\e[1;36m'      # Заголовки и жирный текст (голубой/cyan)
      export LESS_TERMCAP_me=$'\e[0m'         # Конец жирного/мигания
      export LESS_TERMCAP_so=$'\e[01;44;33m'  # Выделение/поиск (желтый на синем фоне)
      export LESS_TERMCAP_se=$'\e[0m'         # Конец выделения
      export LESS_TERMCAP_us=$'\e[1;32m'      # Подчеркивание/аргументы команд (зеленый)
      export LESS_TERMCAP_ue=$'\e[0m'         # Конец подчеркивания
      export GROFF_NO_SGR=1                   # Заставляет groff использовать termcap вместо ломаных escape-кодов

      # Переходить в папку просто написав её имя
      setopt AUTO_CD

      # Разрешить комментарии с '#' в интерактивном шелле
      setopt INTERACTIVE_COMMENTS

      source ${./prompt.zsh}
      source ${./functions.zsh}
      source ${./keybindings.zsh}
    '';

    historySubstringSearch = {
      enable = true; # Чтоб вверх/вниз учитывал уже написанную команду
      searchUpKey = [ "^[[A" "$terminfo[kcuu1]" ];
      searchDownKey = [ "^[[B" "$terminfo[kcud1]" ];
    };
  };
}
