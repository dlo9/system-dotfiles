{
  config,
  lib,
  pkgs,
  isLinux,
  ...
}:
with lib; let
  ext = path: last (splitString "." path);

  xdgSerdes = {
    toml = (pkgs.formats.toml {}).generate;
    yml = (pkgs.formats.yaml {}).generate;
    yaml = (pkgs.formats.yaml {}).generate;
  };

  xdgSerde = path: xdgSerdes."${ext path}" path;

  xdgFile = path: value: {
    name = path;
    value.source = xdgSerde path value;
  };
in {
  home = {
    shellAliases = {
      # Use modern alternatives to classic unix tools
      # https://github.com/ibraheemdev/modern-unix
      du = "dust";
      df = "duf";
      cat = "bat";
      ls = "eza";
      grep = "rg";
      top = "btm";
      htop = "btm";
      ping = "gping";
      ps = "procs";
      watch = "viddy";
      z = "cd";

      carbonyl = "docker run --rm -it fathyb/carbonyl";
    };

    packages = with pkgs;
    # All systems
      [
        # Modern alternatives without aliases
        fd # Modern `find` alternative
        tealdeer # Simple `man` alternative
        mtr # Max traceroute

        # Modern alternatives with aliases
        du-dust
        duf
        bat
        eza
        ripgrep
        bottom
        gping
        procs
        viddy

        # Cheatsheet-like helpers
        navi
        fzf # Required for navi
        cheat

        # Terminal recorder
        #vhs # Requires chrome
        ttyd

        # Nix utils
        any-nix-shell # Doesn't change the interactive shell when using nix-shell
        alejandra # Formatter
        nix-diff
        nix-tree
        nh # Nix cli helper

        # CSV utils
        miller
        csvlens

        # Other utils
        curl
        go-task
        pv
        sops
        ouch # zip tool, since p7zip is annoying
        zstd
        age
        glow # Markdown reader
        trippy # Network diagnostics
        unstable.nix-inspect
        tailspin # Log highlighter
        dlo9.havn # Port scanner

        # To try
        # 3mux

        # Good tools, but don't need installed all the time
        # topgrade
        # lemmeknow
      ]
      ++
      # Linux only
      (optionals isLinux [
        lshw
        file

        # System utils
        lsof
        pciutils # lspci
        gptfdisk # Disk partitioning (sgdisk)
        inxi # Hardware info
        kmon # Kernel monitor
        flashrom
        iputils # Required by gping

        vulnix # Vulnerability scanner

        immich-cli # Bulk image uploading
        nvtopPackages.intel # GPU monitoring
        noseyparker # Credential scanner
      ]);
  };

  # https://github.com/atuinsh/atuin/issues/952#issuecomment-2163044297
  systemd.user = {
    sockets.atuin = {
      Unit.Description = "Atuin daemon";
      Socket.ListenStream = "%h/.local/share/atuin/atuin.sock"; # Default value for atuin
      Install.WantedBy = ["sockets.target"];
    };

    services.atuin = {
      Unit.Description = "Atuin daemon";
      Service.ExecStart = "${config.programs.atuin.package}/bin/atuin daemon";
    };
  };

  launchd.agents.atuin = {
    enable = true;
    config = {
      KeepAlive = true;
      RunAtLoad = true;
      ProgramArguments = ["${config.programs.atuin.package}/bin/atuin" "daemon"];
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/atuin/stderr";
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/atuin/stdout";
    };
  };

  programs = {
    atuin = {
      enable = mkDefault true;
      enableFishIntegration = config.programs.fish.enable;

      # Remove once stable is up to 18.3.0
      # https://github.com/atuinsh/atuin/issues/952#issuecomment-2163044297
      package = pkgs.master.atuin;

      settings = {
        # inline_height = 25; # https://github.com/atuinsh/atuin/issues/1289
        style = "compact";
        enter_accept = true;
        filter_mode = "session";

        # https://github.com/atuinsh/atuin/issues/952#issuecomment-2163044297
        daemon = {
          enabled = mkDefault true;
          sync_frequency = 60;
          systemd_socket = mkDefault isLinux;
        };
      };
    };

    zoxide = {
      enable = mkDefault true;
      enableFishIntegration = config.programs.fish.enable;
      options = ["--cmd" "cd"];
    };

    bottom = {
      enable = mkDefault true;

      # https://github.com/ClementTsang/bottom/blob/master/sample_configs/default_config.toml
      settings = {
        flags = {
          mem_as_value = true;
        };
      };
    };

    # I don't count this as a developer tool because it's needed for applying nix configs
    git = {
      enable = true;
      userName = "David Orchard";
      userEmail = mkDefault "if_coding@fastmail.com";

      lfs.enable = true;

      ignores = [
        # Temporary files
        "*~"
        "*.swp"
        "*.swo"

        # Backups
        "*.old"

        # Logs
        "*.log"
      ];

      extraConfig = {
        init.defaultBranch = "main";
        pull.ff = "only";
        credential.helper = mkIf isLinux "${pkgs.gitAndTools.gitFull}/bin/git-credential-libsecret";
        push.autoSetupRemote = true;
        merge.conflictStyle = "zdiff3";
      };
    };

    helix = {
      enable = true;
      settings = {
        theme = "kanagawa";
      };
    };

    yazi = {
      enable = true;

      settings = {
        manager = {
          sort_by = "natural";
          sort_sensitive = false;
          sort_reverse = false;
          sort_dir_first = true;
          linemode = "size";
          show_hidden = true;
          show_symlink = true;
        };
      };
    };
  };

<<<<<<< Updated upstream
  xdg.configFile = listToAttrs [
    (xdgFile "tealdeer/config.toml" {
      updates.auto_update = true;
    })
  ];
||||||| Stash base
=======
  xdg.configFile."viddy.toml".source = (pkgs.formats.toml {}).generate "viddy.toml" {
    keymap = {
      timemachine_go_to_past = "Shift-Down";
      timemachine_go_to_future = "Shift-Up";
      timemachine_go_to_now = "Ctrl-Shift-Up";
      timemachine_go_to_oldest = "Ctrl-Shift-Down";
    };
  };
>>>>>>> Stashed changes
}
