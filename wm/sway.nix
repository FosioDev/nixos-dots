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
          # Превратить движение мыши в скрол,
          # когда зажата дальняя боковая кнопка мыши
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
            criteria.app_id = "thunar";
            criteria.title = "Confirm to replace files";
          }
          {
            command = "floating enable, border pixel 1";
            criteria.app_id = "thunar";
            criteria.title = "File Operation Progress";
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

        controls = pkgs.writeScript "controls" ''
          #!/usr/bin/env zsh

          set -euo pipefail

          control="$1"
          value="$2"

          get_audio_info() {
            local dev="@DEFAULT_AUDIO_SINK@"
            [[ $1 == 'mic' ]] && dev="@DEFAULT_AUDIO_SOURCE@"

            local raw=$(wpctl get-volume $dev)
            local parts=($=raw)

            integer -g vol=$(( parts[2] * 100 ))
            is_muted=1
            [[ $raw == *'[MUTED]'* ]] && is_muted=2

            return 0
          }

          # notify <tag> <title> [progress] [body]
          notify() {
            notify-send -t 2000 -h "string:x-canonical-private-synchronous:$1" \
                        ''${3:+-h} ''${3:+int:value:$3} \
                        "$2" ''${4:+"$4"}
          }

          case $control in
            volume)
              wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ "$value"
              get_audio_info sink
              notify volume "  Volume $vol%" $vol
              ;;

            brightness)
              brightnessctl set "$value"
              val=''${''${(s:,:)$(brightnessctl -m)}[4]%\%}
              notify brightness "  Brightness $val%" $val
              ;;

            mute)
              dev="@DEFAULT_AUDIO_SINK@"
              icons=('  Unmuted' '  Muted')

              if [[ $value == 'mic' ]]; then
                dev="@DEFAULT_AUDIO_SOURCE@"
                icons=('  Mic Unmuted' '  Mic Muted')
              fi

              wpctl set-mute $dev toggle
              get_audio_info $value

              notify $value "''${icons[is_muted]} ($vol%)" $vol
              ;;

            media)
              playerctl "$value" 2>/dev/null || {
                notify media "  No player active"
                exit 0
              }
              sleep 0.05

              case $value in
                play-pause) [[ $(playerctl status 2>/dev/null) == 'Playing' ]] && title='  Playing' || title='  Paused' ;;
                next)       title='  Next Track' ;;
                previous)   title='  Previous Track' ;;
                stop)       title='  Stopped' ;;
              esac

              body=$(playerctl metadata --format $'{{title}}\n{{artist}}' 2>/dev/null || true)
              notify media "$title" "" "$body"
              ;;
          esac
        '';

        # '' для экранирования $ в многострочной строке
        screenshot = pkgs.writeShellScript "screenshot" ''
          DIR="$HOME/Pictures/Screenshots"
          TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
          SATTY_CMD=(
            satty -f - --initial-tool=arrow --copy-command="wl-copy"
            --actions-on-enter="save-to-clipboard,save-to-file,exit"
            --actions-on-escape="save-to-clipboard,save-to-file,exit"
            --brush-smooth-history-size=5 --disable-notifications
            --output-filename "$DIR/satty-$TIMESTAMP.png"
          )

          case "$1" in
            area)
              FILE="$DIR/screenshot-$TIMESTAMP.png"
              # Экран заморозится, slurp берет геометрию. Если нажат Esc — GEOM пустой,
              # grim не вызывается, а killall в любом случае отпускает экран.
              wayfreeze --hide-cursor --after-freeze-cmd '
                GEOM=$(slurp)
                [ -n "$GEOM" ] && grim -g "$GEOM" -t png - | tee "'"$FILE"'" | wl-copy
                killall wayfreeze
              '
              ;;

            fullscreen)
              grim -t ppm - | "''${SATTY_CMD[@]}"
              ;;

            window)
              GEOM=$(swaymsg -t get_tree | jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')
              [ -n "$GEOM" ] && grim -t ppm -g "$GEOM" - | "''${SATTY_CMD[@]}"
              ;;
          esac
        '';
      in {
        # Volume
        "--locked XF86AudioRaiseVolume" = "exec ${controls} volume 5%+";
        "--locked XF86AudioLowerVolume" = "exec ${controls} volume 5%-";
        "--locked XF86AudioMute"        = "exec ${controls} mute volume";
        "--locked XF86AudioMicMute"     = "exec ${controls} mute mic";

        # Brightness
        "--locked XF86MonBrightnessUp"   = "exec ${controls} brightness 5%+";
        "--locked XF86MonBrightnessDown" = "exec ${controls} brightness 5%-";

        # Media
        "--locked XF86AudioPlay"  = "exec ${controls} media play-pause";
        "--locked XF86AudioPause" = "exec ${controls} media play-pause";
        "--locked XF86AudioNext"  = "exec ${controls} media next";
        "--locked XF86AudioPrev"  = "exec ${controls} media previous";
        "--locked XF86AudioStop"  = "exec ${controls} media stop";

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
        "${mod}+BackSpace" = "exec ${pkgs.rofi-power-menu}/bin/rofi-power-menu";

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
