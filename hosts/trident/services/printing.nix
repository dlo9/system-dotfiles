{
  config,
  pkgs,
  lib,
  ...
}:
with lib; {
  services.klipper = {
    enable = true;
    user = "moonraker";
    group = "moonraker";

    # Use a mutable config, under moonraker's config path,
    # so that it can be edited in the UI
    mutableConfig = true;
    mutableConfigFolder = "${config.services.moonraker.stateDir}/config";

    # If missing, download LDO's trident template
    configFile = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/MotorDynamicsLab/LDOVoronTrident/39c4e07d7dedf3674d065c4991ffd35998790f8d/Firmware/printer-leviathan-rev-d.cfg";
      hash = "sha256-QF3MwCO3+SQAVqAeSljh6xO0iVQ3t+aEuFcIXUICpDY=";
    };
  };

  # Required for system control
  security.polkit.enable = true;

  services.moonraker = {
    enable = true;

    # Allows restart, shutdown, etc.
    allowSystemControl = true;

    settings = {
      authorization = {
        trusted_clients = [
          "localhost"
          "192.168.1.0/24"
        ];

        cors_domains = [
          "http://localhost"
          "http://trident"
        ];
      };
    };
  };

  services.fluidd.enable = true;

  networking.firewall.allowedTCPPorts = [
    # Fluidd's nginx
    80

    # go2rtc
    1984 # API/webpage
    8555 # webrtc
  ];

  networking.firewall.allowedUDPPorts = [
    8555 # webrtc
  ];

  services.getty.autologinUser = "pi";

  services.cage = {
    enable = true;
    program = "${pkgs.klipperscreen}/bin/KlipperScreen";
    user = "pi";

    environment = {
      WLR_LIBINPUT_NO_DEVICES = "1";
      XDG_RUNTIME_DIR = "/run/user/1000";
    };
  };

  # Rotate the screen after cage starts
  systemd.services."cage-tty1" = rec {

    requires = [ "user.slice" "user@1000.service" ];
    after = [ "user.slice" "user@1000.service" "systemd-user-sessions.service" ];
    serviceConfig = {
      TimeoutStartSec = "30s";
      ExecStartPost = "-${pkgs.writeShellApplication {
        name = "rotate-display";

        runtimeInputs = with pkgs; [
          wlr-randr
          jq
        ];

        text = ''
          # Wait until the session exists
          until [[ -e "$XDG_RUNTIME_DIR/wayland-0" ]]; do
            sleep 1
          done

          display="$(wlr-randr --json | jq -r '.[].name')"
          echo "Rotating display $display"
          wlr-randr --output "$display" --transform 180
        '';
      }}/bin/rotate-display";
    };
  };

  services.go2rtc = {
    enable = true;
    settings = {
      streams.c200 = "ffmpeg:device?video=/dev/video0&input_format=h264&video_size=2560x1440";
      api.origin = "*"; # CORS anywhere
    };
  };
}
