{ config, pkgs, lib, ... }:

with lib;

let
  sysCfg = config.sys;
  cfg = sysCfg.graphical;
in
{
  imports = [
    ./polkit.nix
    ./nvidia
  ];

  options.sys.graphical = {
    enable = mkEnableOption "graphical shell" // { default = true; };
  };

  config = mkIf cfg.enable {
    # Allow swaylock
    security.pam.services.swaylock = { };

    # Auto-login since whole-disk encryption is already required
    services.getty.autologinUser = "${sysCfg.user}";
    environment.loginShellInit = mkDefault ''
      if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
        ${if (elem "nvidia" config.services.xserver.videoDrivers)
          then "exec env WLR_NO_HARDWARE_CURSORS=1 sway --unsupported-gpu"
          else "exec sway"
        }
      fi
    '';

    # Audio
    hardware.pulseaudio.enable = true;

    # Fonts
    fonts = {
      fonts = with pkgs; [
        # Nerdfonts is huge, so only install specific fonts
        # https://github.com/NixOS/nixpkgs/blob/nixos-22.05/pkgs/data/fonts/nerdfonts/shas.nix
        (nerdfonts.override {
          fonts = [
            "Noto"
          ];
        })

        noto-fonts-emoji
      ];

      fontconfig = {
        defaultFonts = {
          serif = [ "NotoSerif Nerd Font" "" ];
          sansSerif = [ "NotoSans Nerd Font" "DejaVu Sans" ];
          monospace = [ "Noto Nerd Font Mono" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };

    # Packages
    environment.systemPackages = with pkgs; [
      # System utils
      gparted # Partitioning
      exfatprogs
      ntfs3g

      # Key tester
      wev

      mpv
      okular
      zathura

      # Keyring
      libsecret

      # Control monitor settings (brightness, contrast, etc.) via GUI
      # Must enable `hardware.i2c.*`
      ddcui

      # Virtualization management
      virt-manager
    ];

    # Enable i2c for the main user to control monitors via software
    hardware.i2c.enable = true;
    users.users."${sysCfg.user}".extraGroups = [ config.hardware.i2c.group ];

    # Printing
    # To add a printer, go to:
    # http://localhost:631/
    services.printing.enable = true;
    services.printing.drivers = [
      # See other drivers at https://nixos.wiki/wiki/Printing
      # Brother drivers
      pkgs.brgenml1lpr
      pkgs.brgenml1cupswrapper
    ];

    # Scanning
    services.saned.enable = true;
    hardware.sane = {
      enable = true;
      drivers.scanSnap.enable = true;
      brscan4 = {
        enable = true;
        netDevices = {
          home = {
            model = "MFC-J480DW";
            nodename = "BRW541379C4810E";
            #ip = "192.168.1.212";
          };
        };
      };
    };

    services.avahi.enable = true;
    services.avahi.nssmdns = true;

    # Add GVFS for samba/cifs, webdav, etc.
    services.gvfs.enable = true;

    # Keyring
    services.gnome.gnome-keyring.enable = true;
  };
}
