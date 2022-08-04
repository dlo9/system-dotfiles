{ config, pkgs, lib, ... }:

with lib;

let
  sysCfg = config.sys;
  cfg = sysCfg.graphical;
in
{
  imports = [
    ./polkit.nix
  ];

  options.sys.graphical = {
    enable = mkEnableOption "graphical shell" // { default = true; };
  };

  config = mkIf cfg.enable {
    # Auto-login since whole-disk encryption is already required
    services.getty.autologinUser = "${sysCfg.user}";
    environment.loginShellInit = ''
      if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
        exec sway
      fi
    '';

    # Add GVFS for samba mounts in file manager
    #services.gvfs.enable = true;
    services.gvfs = {
      enable = true;
      package = lib.mkForce pkgs.gnome3.gvfs;
    };

    # Window manager
    programs.xwayland.enable = true;
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraSessionCommands = ''
        # SDL:
        export SDL_VIDEODRIVER=wayland
        # QT (needs qt5.qtwayland in systemPackages):
        export QT_QPA_PLATFORM=wayland-egl
        export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
        # Fix for some Java AWT applications (e.g. Android Studio),
        # use this if they aren't displayed properly:
        export _JAVA_AWT_WM_NONREPARENTING=1
      '';
      extraPackages = with pkgs; [
        # Core
        swaylock
        swayidle
        swaybg
        waybar

        # Clipboard
        wl-clipboard
        copyq

        # Notifications
        mako

        # Shell
        alacritty

        # Menus and application selection
        wofi
        dex

        # Hardware controls
        brightnessctl
        pavucontrol

        # Display management
        wdisplays
      ];
    };

    # Audio
    hardware.pulseaudio.enable = true;

    # Fonts
    fonts.fonts = with pkgs; [
      # Nerdfonts is huge, so only install specific fonts
      # https://github.com/NixOS/nixpkgs/blob/nixos-22.05/pkgs/data/fonts/nerdfonts/shas.nix
      (nerdfonts.override {
        fonts = [
          "Noto" # If removed, add `noto-fonts-emoji` package to retain emoji support
        ];
      })
    ];

    # Packages
    environment.systemPackages = with pkgs; [
      # System utils
      gparted # Partitioning

      # Web browsers
      qutebrowser
      firefox-wayland
    ];

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

    services.avahi.enable = true;
    services.avahi.nssmdns = true;
  };
}
