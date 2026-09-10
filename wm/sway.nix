{ pkgs, config, lib, ... }: let
    scale = "2"; # Sway scale и фикс захвата окна в obs на HiDPI
in {
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    wlr = {
      enable = true;
      settings = {
        screencast = {
          chooser_type = "dmenu";
          chooser_cmd = "${pkgs.rofi}/bin/rofi -dmenu -i -p 'Share:' -theme-str 'window {width: 40%;}'";
        };
      };
    };
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };

  # Хранилище настроек для GTK и Gnome приложений
  # Если не работает, то сделай ресет
  # dconf reset -f /org/gtk/
  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        # Нормальная сортировка файлов у GTK File Chooser
        settings = {
          "org/gtk/settings/file-chooser" = {
            sort-directories-first = true;
            sort-column = "name";
            sort-order = "ascending";
          };
          "org/gtk/gtk4/settings/file-chooser" = {
            sort-directories-first = true;
            sort-column = "name";
            sort-order = "ascending";
          };
        };
      }
    ];
  };

  # Fix HiDPI window screensharing blur
  nixpkgs.overlays = [
    (final: prev: {
      sway-unwrapped = prev.sway-unwrapped.overrideAttrs (oldAttrs: {
        buildInputs = map (pkg:
          if (pkg.pname or "") == "wlroots" || prev.lib.hasPrefix "wlroots" (pkg.name or "")
          then pkg.overrideAttrs (old: {
            postPatch = (old.postPatch or "") + ''
              substituteInPlace types/ext_image_capture_source_v1/scene.c \
                --replace-fail 'wlr_output_state_set_custom_mode(&state, extents.width, extents.height, 0);' \
                               'wlr_output_state_set_custom_mode(&state, ${scale}*extents.width, ${scale}*extents.height, 0); wlr_output_state_set_scale(&state, ${scale});'
            '';
          })
          else pkg
        ) oldAttrs.buildInputs;
      });
    })
  ];

  programs.sway = {
    enable = true;

    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland-egl
      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      export _JAVA_AWT_WM_NONREPARENTING=1
    '';
  };

  hm.wayland.systemd.target = "sway-session.target";

  # https://github.com/swaywm/sway/wiki
  hm.wayland.windowManager.sway = {
    enable = true;

    systemd.enable = true;

    config = {
      # В стоке hm добавляет много дерьма
      bars = [ ];
      modes = { };
      terminal = "";
      up = "";
      down = "";
      left = "";
      right = "";
      menu = "";

      defaultWorkspace = "workspace number 1";
      modifier = "Mod4";

      # swaymsg -t get_outputs
      output = {
        "*".bg = "${../themes/media/1.png} fill";
        DP-3 = {
          scale = scale;
          mode = "3840x2160@160Hz";
        };
        # Virtual-1 = {
        #   scale = scale;
        #   mode = "3840x2160@60Hz";
        # };
      };

      input = {
        "type:pointer" = {
          accel_profile = "flat";
          scroll_method = "on_button_down";
          scroll_button = "276"; # sudo libinput debug-events --show-keycodes
          middle_emulation = "disabled";
        };
        "type:keyboard" = {
          xkb_layout = "us,ru";
          xkb_options = "grp:caps_toggle";
        };
      };

      colors = lib.mkForce {
        focused = {
          border = config.my.colors.base09;
          background = config.my.colors.base09;
          text = config.my.colors.base00;
          indicator = config.my.colors.base09;
          childBorder = config.my.colors.base09;
        };
        focusedInactive = {
          border = config.my.colors.base0B;
          background = config.my.colors.base0B;
          text = config.my.colors.base00;
          indicator = config.my.colors.base0B;
          childBorder = config.my.colors.base0B;
        };
        unfocused = {
          border = config.my.colors.base0B;
          background = config.my.colors.base0B;
          text = config.my.colors.base00;
          indicator = config.my.colors.base0B;
          childBorder = config.my.colors.base0B;
        };
      };

      gaps.inner = 3;

      focus = {
        mouseWarping = false;
        followMouse = "always";
      };

      floating = {
        border = 1;
        titlebar = false;

        # Drag floating windows by holding down $mod and left mouse button.
        # Resize them with right mouse button + $mod.
        # Despite the name, also works for non-floating windows.
        # Change normal to inverse to use left mouse button for resizing and right
        # mouse button for dragging.
        modifier = config.hm.wayland.windowManager.sway.config.modifier;
      };

      window = {
        border = 1;
        titlebar = false;

        # Узнать app_id: swaymsg -t get_tree | less
        # example: for_window [app_id="firefox" title="Picture-in-Picture"] floating enable
        # значения вроде title поддерживают регулярные выражения
        commands = [
          {
            command = "floating enable, resize set 70 ppt 80 ppt, move position center";
            criteria.app_id = "floating_term";
          }
          {
            command = "floating enable, resize set width 50 ppt height 60 ppt, move position center";
            criteria.app_id = "pavucontrol";
          }
          {
            command = "floating enable";
            criteria.app_id = "nm-connection-editor";
          }
          {
            command = "floating enable, border pixel 1";
            criteria.app_id = "xdg-desktop-portal-gtk";
          }
          {
            command = "floating enable, border pixel 1";
            criteria.app_id = "thunar";
            criteria.title = "Rename.*";
          }
          {
            command = "floating enable, border pixel 1";
            criteria.app_id = "md.Obsidian";
            criteria.title = "Settings.*";
          }
          {
            command = "floating enable, border pixel 1";
            criteria.app_id = "soffice";
            criteria.title = "Open";
          }
          {
            command = "floating enable, resize set 80 ppt 90 ppt, move position center";
            criteria.app_id = "com.gabm.satty";
          }
        ];
      };

      # На каком воркспейсе открывать приложение
      # assigns = {};

      keybindings = let
        mod = config.hm.wayland.windowManager.sway.config.modifier;

        # Управление громкостью (плюс, минус, мут) (лимит 150%)
        volumeNotify = pkgs.writeShellScript "volume-notify" ''
          case "$1" in
            raise)
              ${pkgs.wireplumber}/bin/wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+
              ;;
            lower)
              ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
              ;;
            mute)
              ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
              ;;
          esac

          # Получаем состояние
          VOL_STATUS=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@)
          # Преобразуем float (0.65) в проценты (65)
          VOL=$(echo "$VOL_STATUS" | ${pkgs.gawk}/bin/awk '{print int($2 * 100)}')

          if echo "$VOL_STATUS" | ${pkgs.gnugrep}/bin/grep -q '\[MUTED\]'; then
            ${pkgs.dunst}/bin/dunstify -r 91190 -t 800 -h int:value:"$VOL" "  Muted ($VOL%)"
          else
            ${pkgs.dunst}/bin/dunstify -r 91190 -t 800 -h int:value:"$VOL" "  Volume: $VOL%"
          fi
        '';

        # Управление микрофоном
        micNotify = pkgs.writeShellScript "mic-notify" ''
          ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

          if ${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | ${pkgs.gnugrep}/bin/grep -q '\[MUTED\]'; then
            ${pkgs.dunst}/bin/dunstify -r 91191 -t 800 "  Mic Muted"
          else
            ${pkgs.dunst}/bin/dunstify -r 91191 -t 800 "  Mic Unmuted"
          fi
        '';

        # Управление яркостью
        brightnessNotify = pkgs.writeShellScript "brightness-notify" ''
          case "$1" in
            up)
              ${pkgs.brightnessctl}/bin/brightnessctl set 5%+
              ;;
            down)
              ${pkgs.brightnessctl}/bin/brightnessctl set 5%-
              ;;
          esac

          # Получаем процент яркости
          BRIGHTNESS=$(${pkgs.brightnessctl}/bin/brightnessctl -m | ${pkgs.gawk}/bin/awk -F, '{gsub(/%/,"",$4); print $4}')
          ${pkgs.dunst}/bin/dunstify -r 91192 -t 800 -h int:value:"$BRIGHTNESS" "  Brightness: $BRIGHTNESS%"
        '';

        # Управление медиа
        mediaNotify = pkgs.writeShellScript "media-notify" ''
          ACTION="$1"
          PLAYERCTL="${pkgs.playerctl}/bin/playerctl"
          DUNSTIFY="${pkgs.dunst}/bin/dunstify"

          # Выполняем команду. Если плееров нет вовсе — выводим сообщение и выходим
          if ! $PLAYERCTL $ACTION 2>/dev/null; then
            $DUNSTIFY -r 91193 -t 1000 "  No player active"
            exit 0
          fi

          # Микро-пауза, чтобы плеер успел изменить статус и метаданные
          sleep 0.05

          case "$ACTION" in
            play-pause)
              STATUS=$($PLAYERCTL status 2>/dev/null || echo "Unknown")
              if [ "$STATUS" = "Playing" ]; then
                ICON=" "
                TITLE="Playing"
              else
                ICON=" "
                TITLE="Paused"
              fi
              ;;
            next)
              ICON=" "
              TITLE="Next Track"
              ;;
            previous)
              ICON=" "
              TITLE="Previous Track"
              ;;
            stop)
              $DUNSTIFY -r 91193 -t 1500 "  Stopped"
              exit 0
              ;;
          esac

          # Подтягиваем название трека и исполнителя (если плеер их отдает)
          TRACK=$($PLAYERCTL metadata --format '{{title}}' 2>/dev/null)
          ARTIST=$($PLAYERCTL metadata --format '{{artist}}' 2>/dev/null)

          if [ -n "$TRACK" ]; then
            if [ -n "$ARTIST" ]; then
              $DUNSTIFY -r 91193 -t 2000 "$ICON $TITLE" "$TRACK\n$ARTIST"
            else
              $DUNSTIFY -r 91193 -t 2000 "$ICON $TITLE" "$TRACK"
            fi
          else
            $DUNSTIFY -r 91193 -t 1500 "$ICON $TITLE"
          fi
        '';

        screenshot = pkgs.writeShellScript "screenshot" ''
          DIR="$HOME/Pictures/Screenshots"

          TIMESTAMP=$(date '+%Y%m%d-%H%M%S')

          SATTY_CMD=(
            ${pkgs.satty}/bin/satty
            -f -
            --initial-tool=arrow
            --copy-command="${pkgs.wl-clipboard}/bin/wl-copy"
            --actions-on-enter="save-to-clipboard,save-to-file,exit"
            --actions-on-escape="save-to-clipboard,save-to-file,exit"
            --brush-smooth-history-size=5
            --disable-notifications
            --output-filename "$DIR/satty-$TIMESTAMP.png"
          )

          case "$1" in
            area)
              # Заморозка экрана
              ${pkgs.wayfreeze}/bin/wayfreeze --hide-cursor --after-freeze-cmd "
                GEOM=\$(${pkgs.slurp}/bin/slurp)

                if [ -n \"\$GEOM\" ]; then
                  FILE=\"$DIR/screenshot-$TIMESTAMP.png\"

                  # 1. grim забирает именно замороженный кадр
                  ${pkgs.grim}/bin/grim -g \"\$GEOM\" -t png - | \
                    ${pkgs.coreutils}/bin/tee \"\$FILE\" | \
                    ${pkgs.wl-clipboard}/bin/wl-copy

                  # 2. Кадр взят — сразу размораживаем экран
                  ${pkgs.killall}/bin/killall wayfreeze

                  # 3. Уведомление в фоне
                  ${pkgs.dunst}/bin/dunstify -r 91194 -t 2000 'Screenshot saved' 'Area copied to clipboard'
                else
                  # Если нажали Esc — сразу отпускаем экран, ничего не сохраняя
                  ${pkgs.killall}/bin/killall wayfreeze
                fi
              "
              ;;

            fullscreen)
              ${pkgs.grim}/bin/grim -t ppm - | "''${SATTY_CMD[@]}"
              ;;

            window)
              GEOM=$(${pkgs.sway}/bin/swaymsg -t get_tree | ${pkgs.jq}/bin/jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')
              if [ -n "$GEOM" ]; then
                ${pkgs.grim}/bin/grim -t ppm -g "$GEOM" - | "''${SATTY_CMD[@]}"
              fi
              ;;
          esac
        '';
      in {
        # Volume
        "--locked XF86AudioMute"         = "exec ${volumeNotify} mute";
        "--locked XF86AudioLowerVolume"  = "exec ${volumeNotify} lower";
        "--locked XF86AudioRaiseVolume"  = "exec ${volumeNotify} raise";
        "--locked XF86AudioMicMute"      = "exec ${micNotify}";

        # Media
        "--locked XF86AudioPlay"  = "exec ${mediaNotify} play-pause";
        "--locked XF86AudioPause" = "exec ${mediaNotify} play-pause";
        "--locked XF86AudioPrev"  = "exec ${mediaNotify} previous";
        "--locked XF86AudioNext"  = "exec ${mediaNotify} next";
        "--locked XF86AudioStop"  = "exec ${mediaNotify} stop";

        # Brightness
        "--locked XF86MonBrightnessDown" = "exec ${brightnessNotify} down";
        "--locked XF86MonBrightnessUp"   = "exec ${brightnessNotify} up";

        # Take a screenshot
        "Print"       = "exec ${screenshot} area";
        "Shift+Print" = "exec ${screenshot} fullscreen";
        "Ctrl+Print"  = "exec ${screenshot} window";

        # Color picker
        "${mod}+Shift+c" = "exec grim -g \"$(slurp -p)\" -t ppm - | magick - -format '%[hex:u]' info: | wl-copy";

        # Close focused window
        "${mod}+q" = "kill";

        # Reload the configuration file
        "${mod}+Shift+Ctrl+Alt+r" = "reload";

        # Exit sway (logs you out of your Wayland session)
        "${mod}+Shift+Ctrl+Alt+q" = "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -B 'Yes, exit sway' 'swaymsg exit'";

        # Terminal
        "${mod}+t" = "exec alacritty";
        "${mod}+Shift+t" = "exec alacritty --class floating_term";

        # Applications
        "${mod}+a" = "exec rofi -show drun -theme ~/.config/rofi/launcher.rasi";

        # Calculator
        "${mod}+c" = "exec rofi -show calc -modi calc -no-show-match -no-sort -theme ~/.config/rofi/launcher.rasi";

        # Passwords
        "${mod}+p" = "exec rofi-pass";

        # Clipboard history
        "${mod}+v" = "exec cliphist list | rofi -dmenu -p \"Clipboard\" -theme-str 'window { padding: 5px; border: 1px; }' | cliphist decode | wl-copy";
        "${mod}+Ctrl+v" = "exec cliphist list | rofi -dmenu -p \"Delete\" -theme-str 'window { padding: 5px; border: 1px; }' | cliphist delete";

        # Power menu
        "${mod}+BackSpace" = "exec rofi -show powermenu -modi powermenu:${pkgs.rofi-power-menu}/bin/rofi-power-menu -theme ~/.config/rofi/power.rasi";

        # Switch to workspace
        "${mod}+1" = "workspace number 1";
        "${mod}+2" = "workspace number 2";
        "${mod}+3" = "workspace number 3";
        "${mod}+4" = "workspace number 4";
        "${mod}+5" = "workspace number 5";
        "${mod}+6" = "workspace number 6";
        "${mod}+7" = "workspace number 7";
        "${mod}+8" = "workspace number 8";
        "${mod}+9" = "workspace number 9";
        "${mod}+0" = "workspace number 10";

        # Move focused container to workspace
        "${mod}+Shift+1" = "move container to workspace number 1";
        "${mod}+Shift+2" = "move container to workspace number 2";
        "${mod}+Shift+3" = "move container to workspace number 3";
        "${mod}+Shift+4" = "move container to workspace number 4";
        "${mod}+Shift+5" = "move container to workspace number 5";
        "${mod}+Shift+6" = "move container to workspace number 6";
        "${mod}+Shift+7" = "move container to workspace number 7";
        "${mod}+Shift+8" = "move container to workspace number 8";
        "${mod}+Shift+9" = "move container to workspace number 9";
        "${mod}+Shift+0" = "move container to workspace number 10";

        # Move your focus around
        "${mod}+Left"  = "focus left";
        "${mod}+Down"  = "focus down";
        "${mod}+Up"    = "focus up";
        "${mod}+Right" = "focus right";

        # Move the focused window with the same, but add Shift
        "${mod}+Shift+Ctrl+Left"  = "move left";
        "${mod}+Shift+Ctrl+Down"  = "move down";
        "${mod}+Shift+Ctrl+Up"    = "move up";
        "${mod}+Shift+Ctrl+Right" = "move right";

        # Resize the focused window
        "${mod}+Shift+Left"  = "resize shrink width  30px";
        "${mod}+Shift+Right" = "resize grow   width  30px";
        "${mod}+Shift+Down"  = "resize grow   height 30px";
        "${mod}+Shift+Up"    = "resize shrink height 30px";

        # Horizontal and vertical splits
        "${mod}+Shift+h" = "splith";
        "${mod}+Shift+v" = "splitv";

        # Switch the current container between different layout styles
        "${mod}+Shift+s" = "layout stacking";
        "${mod}+Shift+w" = "layout tabbed";
        "${mod}+Shift+e" = "layout toggle split";

        # Make the current focus fullscreen
        "${mod}+Return" = "fullscreen";

        # Toggle the current focus between tiling and floating mode
        "${mod}+f" = "floating toggle";

        # Swap focus between the tiling area and the floating area
        # "${mod}+space" = "focus mode_toggle";

        # Switch to previous workspace
        "${mod}+Super_R" = "workspace back_and_forth";

        # Browsers
        "${mod}+b" = "exec librewolf";
        "${mod}+Shift+b" = "exec firefox";
        "${mod}+Shift+Ctrl+b" = "exec chromium";

        # Note taking app
        "${mod}+n" = "exec obsidian";

        # Explorer
        "${mod}+e" = "exec thunar";

        # Sway has a "scratchpad", which is a bag of holding for windows.
        # You can send windows there and get them back later.
        # Move the currently focused window to the scratchpad
        "${mod}+Shift+minus" = "move scratchpad";
        # Show the next scratchpad window or hide the focused scratchpad window.
        # If there are multiple scratchpad windows, this command cycles through them.
        "${mod}+minus" = "scratchpad show";
      };

      startup = [
        # always = true; будет запускать команду при каждом ребуте sway
        # { command = "systemctl --user restart waybar"; always = true; }
        { command = "waybar"; }
        { command = "nm-applet"; }
        { command = "wl-paste --watch cliphist -max-items 100 store"; }
      ];
    };

    # extraConfigEarly = '''';

    # Не уверен надо ли, мб hm сам добавляет что надо
    extraConfig = ''
      include /etc/sway/config.d/*
    '';
  };
}
