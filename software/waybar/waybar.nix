{ pkgs, config, inputs, ... }: {

  hm.programs.waybar = {
    enable = true;
    package = inputs.waybar.packages.${pkgs.stdenv.hostPlatform.system}.default;

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
          "sway/scratchpad" #"custom/separator"
          "custom/mchose" "custom/separator"
          "cpu" "custom/separator" "memory" "custom/separator"
          "tray" "custom/separator" "sway/language" "custom/separator"
          "custom/rofi" "custom/separator" "custom/power"
        ];

        "custom/separator" = {
          format = "|";
          interval = "once";
          tooltip = false;
        };

        "custom/mchose" = {
          # С информацией при наведении
          # exec = "${pkgs.writeScript "mchose-waybar" (builtins.readFile ./mchose-waybar.zsh)}";

          # Только заряд, без доп инфы при наведении
          exec = "${pkgs.writeScript "mchose-waybar" (builtins.readFile ./mchose-waybar-min.zsh)}";
          return-type = "json";
          interval = 30;
          on-click = "mchose-gui";
        };

        "custom/rofi" = {
          format = "";
          on-click = "rofi -show drun -show-icons -theme ~/.config/rofi/launcher.rasi";
          tooltip = false;
        };

        "custom/power" = {
          format = "";
          on-click = "${pkgs.rofi-power-menu}/bin/rofi-power-menu";
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
          format = " {usage}%";
          tooltip = false;
        };

        memory = {
          interval = 5;
          format = " {used:0.1f}G + {swapUsed:0.1f}G";
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

      #custom-mchose.connected {
        color: ${config.my.colors.base05};
      }
      #custom-mchose.warning {
        color: ${config.my.colors.base0A};
      }
      #custom-mchose.critical {
        color: ${config.my.colors.base08};
      }
      #custom-mchose.charging {
        color: ${config.my.colors.base0B};
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
