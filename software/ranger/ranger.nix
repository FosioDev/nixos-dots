{ pkgs, config, ... }: {
  environment.systemPackages = with pkgs; [ ranger ];

  hm.programs.ranger = {
    enable = true;

    # В комментах зависимости, которые качаются в packages.nix
    # Тут только их описание будет
    extraPackages = with pkgs; [
      # Preview
      # ueberzugpp # Preview images
      # imagemagick # Preview and auto-rotate images
      # librsvg # Preview SVG
      # ffmpeg_7 # Preview videos
      # ffmpegthumbnailer # Preview videos
      # bat # Syntax highlighting of code
      # unrar # Preview archives
      lynx # Preview html pages
      # poppler # Preview PDF
      djvulibre # Preview djvu
      # calibre # Preview ebooks (or epub-thumbnailer)
      catdoc # Preview XLS as csv conversion
      # exiftool # Information about media files
      odt2txt # For OpenDocument text files
      # jq # Preview JSON
      # sqlite # Listing tables in SQLite database
      # sqlite-utils # Fancier box drawing (optional)
      fontforge # Preview font
      # openscad # 3D model previews (`stl`, `off`, `dxf`, `scad`, `csg`)
      # drawio # Preview draw.io diagram
      pandoc # Preview DOCX, ePub, FB2, odt, ods, odp, sxw, html (using markdown)
      
      # Plugins
      # fd # for file searching
      # fzf # for quick file subtree navigation
      zoxide # for historical directories navigation
      # xclip # for system clipboard support on x11
      # wl-clipboard # for system clipboard support on wayland
    ];

    plugins = [
      { # Нечёткий поиск по каталогу
        name = "ranger-fzf-filter";
        src = fetchGit {
          url = "https://github.com/MuXiu1997/ranger-fzf-filter";
          rev = "bf16de2e4ace415b685ff7c58306d0c5146f9f43";
        };
      }
      { # Иконки для файлов. Требует nerd шрифт
        name = "ranger-devicons";
        src = fetchGit {
          url = "https://github.com/alexanderjeurissen/ranger_devicons";
          rev = "a8d626485ca83719e1d8d5e32289cd96a097c861";
        };
      }
      # { # Другой вариант иконок. Красивее для файлов, хуже для каталогов. Требует изменить default_linemode в rc.conf
      #   name = "ranger-devicons2";
      #   src = fetchGit {
      #     url = "https://github.com/cdump/ranger-devicons2";
      #     rev = "9606009aa01743768b0f27de0a841f7d8fe196c5";
      #   };
      # }
    ];
  };

  hm.xdg.configFile = {
    "ranger/rc.conf".source = ./rc.conf;
    "ranger/rifle.conf".source = ./rifle.conf;
    "ranger/scope.sh" = { source = ./scope.sh; executable = true; };
    "ranger/commands.py" = { source = ./commands.py; executable = true; };
  };
}
