# Потушить экран: swaymsg "output * dpms off"
# Swaybar не даёт выключить скрол по воркспейсам, поэтому убрал

{ pkgs, config, lib, ... }: {
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    wlr.enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };

  programs.sway = {
    enable = true;
    # xwayland.enable = false;
    # wrapperFeatures.gtk = true;

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
    # xwayland = false;
    # wrapperFeatures.gtk = true;

    systemd.enable = true;
    # systemd.variables = [
    #   "DISPLAY"
    #   "WAYLAND_DISPLAY"
    #   "SWAYSOCK"
    #   "XDG_CURRENT_DESKTOP"
    #   "XDG_SESSION_TYPE"
    #   "NIXOS_OZONE_WL"
    #   "XCURSOR_THEME"
    #   "XCURSOR_SIZE"
    # ];

    # extraSessionCommands = ''
    #   export SDL_VIDEODRIVER=wayland
    #   export QT_QPA_PLATFORM=wayland-egl
    #   export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
    #   export _JAVA_AWT_WM_NONREPARENTING=1
    # '';

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
          scale = "2";
          mode = "3840x2160@160Hz";
        };
        # Virtual-1 = {
        #   scale = "2";
        #   mode = "3840x2160@60Hz";
        # };
      };

      input = {
        "type:pointer" = {
          accel_profile = "flat";
          scroll_method = "on_button_down";
          scroll_button = "276"; # wev
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
            command = "floating enable, resize set 80 ppt 80 ppt, move position center";
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
            command = "floating enable, resize set 80 ppt 90 ppt, move position center";
            criteria.app_id = "com.gabm.satty";
          }
        ];
      };

      # На каком воркспейсе открывать приложение
      # assigns = {};

      keybindings = let
        mod = config.hm.wayland.windowManager.sway.config.modifier;
        satty = ''
          satty -f - --initial-tool=arrow --copy-command=wl-copy \
            --actions-on-enter="save-to-clipboard,save-to-file,exit" \
            --actions-on-escape="save-to-clipboard,save-to-file,exit" \
            --brush-smooth-history-size=5 --disable-notifications \
            --output-filename ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H%M%S').png
        '';
        focused = "swaymsg -t get_tree | jq -r '.. | select(.focused?) | .rect | \"\\(.x),\\(.y) \\(.width)x\\(.height)\"'";
      in {

        # Take a screenshot
        # Area + freeze
        "Print" = ''
          wayfreeze --hide-cursor --after-freeze-cmd 'grim -g "$(slurp)" -t png - | \
          tee ~/Pictures/Screenshots/screenshot-$(date '+%Y%m%d-%H%M%S').png | \
          wl-copy; killall wayfreeze'
        '';
        # Fullscreen + crop/draw
        "Shift+Print" = "grim -t ppm - | ${satty}";
        # Window + crop/draw
        "Ctrl+Print" = "${focused} | grim -t ppm -g - - | ${satty}";

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

        # Volume
        "--locked XF86AudioMute"         = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "--locked XF86AudioLowerVolume"  = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "--locked XF86AudioRaiseVolume"  = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "--locked XF86AudioMicMute"      = "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";

        # Media
        "--locked XF86AudioPlay" = "exec playerctl play-pause";
        "--locked XF86AudioPause" = "exec playerctl play-pause";
        "--locked XF86AudioPrev" = "exec playerctl previous";
        "--locked XF86AudioNext" = "exec playerctl next";
        "--locked XF86AudioStop" = "exec playerctl stop";

        # Brightness
        "--locked XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
        "--locked XF86MonBrightnessUp" = "exec brightnessctl set 5%+";

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
