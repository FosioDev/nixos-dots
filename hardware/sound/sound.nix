{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    pavucontrol
    # pwvucontrol # Замена pavucontrol для PipeWire
    alsa-utils # Мне для команды amixer надо
    easyeffects # PipeWire settings. Мне для эквалайзера нужен
  ];

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    wireplumber = {
      enable = true;
      extraScripts."99-stop-microphone-auto-adjust.lua" = ''
        table.insert (default_access.rules,{
          matches = {
            {
              { "application.process.binary", "=", "*" }
            }
          },
          default_permissions = "r-x",
        })
        table.insert (default_access.rules,{
          matches = {
            {
              { "application.process.binary", "=", ".pavucontrol-wrapped" }
            },
            {
              { "application.process.binary", "=", ".easyeffects-wrapped" }
            }
          },
          default_permissions = "rwx",
        })
      '';
    };

    extraConfig.pipewire = {
      "10-clock-rate" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.allowed-rates" = [ 44100 48000 88200 96000 176400 192000 ];
          # "default.clock.allowed-rates" = [ 44100 48000 88200 96000 176400 192000 352800 384000 705600 768000 ];
        };
      };
      # "92-low-latency" = { 
      #   default.clock.quantum = 32; # default = 1024
      #   default.clock.min-quantum = 32; # default = 32
      #   default.clock.max-quantum = 32; # default = 2048
      # };
    };
  };
}
