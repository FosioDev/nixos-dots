{ pkgs, config, ... }: {

  hm.services.dunst = {
    enable = true;

    settings = {
      global = {
        monitor = 0;
        follow = "mouse";

        width = 300;
        height = "(0, 300)";
        origin = "top-right";
        offset = "(20, 20)";
        scale = 0;
        notification_limit = 20;

        # dunstify -h int:value:50 "Загрузка" "Процесс загрузки на 50%"
        progress_bar = true;
        progress_bar_height = 10;
        progress_bar_frame_width = 1;
        progress_bar_min_width = 150;
        progress_bar_max_width = 300;

        indicate_hidden = "yes";
        padding = 6;
        horizontal_padding = 6;
        text_icon_padding = 0;
        frame_width = 3;
        sort = "no";
        separator_height = 2;
        idle_threshold = 0;
        line_height = 3;
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "center";
        vertical_alignment = "center";
        show_age_threshold = -1;
        ellipsize = "middle";
        ignore_newline = "no";
        stack_duplicates = true;
        hide_duplicate_count = true;
        show_indicators = "no";
        word_wrap = "yes";
        enable_recursive_icon_lookup = true;
        icon_position = "off";
        sticky_history = "yes";
        history_length = 15;
        dmenu = "${pkgs.rofi}/bin/rofi -dmenu -p dunst:";
        browser = "${pkgs.xdg-utils}/bin/xdg-open";
        always_run_script = true;
        title = "Dunst";
        class = "Dunst";
        corner_radius = 0;
        ignore_dbusclose = false;
        force_xinerama = false;
        mouse_left_click = "close_current";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click = "close_all";
      };
      urgency_low.timeout = 4;
      urgency_normal.timeout = 6;
      urgency_critical.timeout = 8;
    };
  };
}
