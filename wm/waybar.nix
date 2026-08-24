{ pkgs, config, ... }: {

  hm.programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        reload_style_on_change = true;
        layer = "top";
        position = "bottom";
        height = 30;
        margin = "0";
        spacing = 4;

        modules-left = [ "sway/workspaces" "custom/separator" "sway/window" ];
        modules-center = [ "clock" ];
        modules-right = [
          "sway/scratchpad" "custom/separator"
          "cpu" "custom/separator" "memory" "custom/separator"
          "tray" "custom/separator" "sway/language" "custom/separator"
          "custom/rofi" "custom/separator" "custom/power"
        ];

        "custom/separator" = {
          format = "|";
          interval = "once";
          tooltip = false;
        };

        "custom/rofi" = {
          format = "";
          on-click = "rofi -show drun -show-icons -theme ~/.config/rofi/launcher.rasi";
          tooltip = false;
        };

        "custom/power" = {
          format = "";
          on-click = "rofi -show powermenu -modi powermenu:${pkgs.rofi-power-menu}/bin/rofi-power-menu -theme ~/.config/rofi/power.rasi";
          tooltip = false;
        };

        "sway/workspaces" = {
          disable-scroll = true;
          format = "{icon}";
          format-icons = {
            "1"="1"; "2"="2"; "3"="3"; "4"="4"; "5"="5";
            "6"="6"; "7"="7"; "8"="8"; "9"="9"; "10"="0";
          };
          persistent-workspaces = {
            "1"=[]; "2"=[]; "3"=[]; "4"=[]; "5"=[];
            "6"=[]; "7"=[]; "8"=[]; "9"=[]; "10"=[];
          };
        };

        "sway/window" = {
          format = "{title}";
          format-alt = "NULL";
          max-length = 35;
        };

        "sway/language" = {
          format = "{short}";
          on-click = "swaymsg input type:keyboard xkb_switch_layout next";
          tooltip = false;
        };

        "sway/scratchpad" = {
            format = "{icon} {count}";
            show-empty = false;
            format-icons = ["" ""];
            tooltip = true;
            tooltip-format = "{app}: {title}";
        };

        clock = {
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            format = "{:%d %B %Y %H:%M:%S}";
            format-alt = "{:%d-%m-%Y %H:%M}";
            interval = 1;
            calendar = {
                format = {
                    today = "<span color='${config.my.colors.base09}'>{}</span>";
                };
            };
        };

        tray = {
          icon-size = 20;
          spacing = 4;
        };

        cpu = {
          interval = 1;
          format = "CPU {usage}%";
          tooltip = false;
        };

        memory = {
          interval = 5;
          format = "RAM {used:0.1f}G + {swapUsed:0.1f}G";
          tooltip = false;
        };
      };
    };

    style = ''
      * {
          all: unset;
          font-family: "JetBrainsMonoNL Nerd Font Mono", monospace;
      }

      window#waybar {
          background-color: ${config.my.colors.base00};
          color: ${config.my.colors.base05};
      }

      tooltip {
          background-color: ${config.my.colors.base00};
          color: ${config.my.colors.base05};
          border: 1px solid ${config.my.colors.base05};
      }

      #tray menu {
          background-color: ${config.my.colors.base00};
          color: ${config.my.colors.base05};
          border: 1px solid ${config.my.colors.base05};
          padding: 5px;
      }

      #tray menu menuitem {
          border: 1px solid transparent;
          padding: 4px;
      }

      #tray menu menuitem:hover {
          background-color: ${config.my.colors.base01};
          color: ${config.my.colors.base05};
          border: 1px solid ${config.my.colors.base05};
      }

      #custom-separator {
          color: ${config.my.colors.base09};
      }

      #custom-rofi {
          font-size: 20px;
          margin-top: 1px;
      }

      #custom-power {
          font-size: 20px;
          margin-right: 10px;
      }

      #language {
          font-size: 18px;
      }

      #workspaces button {
          min-width: 24px;
          margin: 4px 0 4px 4px;
          background-color: ${config.my.colors.base05};
          color: ${config.my.colors.base00};
      }

      #workspaces button.urgent {
          background-color: ${config.my.colors.base08};
      }

      #workspaces button.empty {
          background-color: ${config.my.colors.base03};
      }

      #workspaces button.focused,
      #workspaces button.visible {
          background-color: ${config.my.colors.base09};
      }

      #workspaces button:hover {
          background-color: ${config.my.colors.base01};
          color: ${config.my.colors.base05};
      }
    '';
  };
}
