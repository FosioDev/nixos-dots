{ config, lib, ... }: {
  hm.programs.starship = {
    enable = true;

    enableBashIntegration = true;
    enableZshIntegration = true;
    # enableFishIntegration = true;
    # enableNushellIntegration = true;

    # enableTransience = true; # Fish Shell only. Отображает пустую строку при нажатии enter?

    settings = lib.importTOML ./starship.toml;
  };
}
