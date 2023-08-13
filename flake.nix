{
  inputs = {
    # Path types: https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html#types
    nixpkgs-unstable.url = github:NixOS/nixpkgs/nixpkgs-unstable;
    nixpkgs.url = github:NixOS/nixpkgs/nixos-23.05;

    # Old release for EOL kernel 6.2. 6.1 doesn't support Intel ARC, and 6.3 doesn't support ZFS.
    # 6.2 was removed in https://github.com/NixOS/nixpkgs/commit/10d5a682701d1bfd16e62459026d0df54cc3d314
    # TODO: Remove once 6.3 supports ZFS
    nixpkgs-kernel.url = github:NixOS/nixpkgs/nixpkgs-unstable;

    # Available modules: https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    check_mk_agent = {
      url = "github:BenediktSeidl/nixos-check_mk_agent-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets management
    sops-nix = {
      url = github:Mic92/sops-nix;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home manager
    home-manager = {
      # TODO: change back when babelfish commit is in the stable release:
      # https://github.com/nix-community/home-manager/commit/53ccbe017079d5fba2b605cb9f9584629bebd03a
      #url = github:nix-community/home-manager/release-23.05;
      url = github:nix-community/home-manager/53ccbe017079d5fba2b605cb9f9584629bebd03a;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Docker-compose in Nix
    arion = {
      url = github:hercules-ci/arion;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = github:nix-community/NUR;

    vscode-server = {
      url = "github:msteen/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Disk partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mobile-nixos = {
      # path:/home/david/code/mobile-nixos
      url = github:NixOS/mobile-nixos;
      flake = false;
    };

    # Theming
    # A decent alternative (can generate color from picture): https://git.sr.ht/~misterio/nix-colors
    base16 = {
      url = github:SenchoPens/base16.nix;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Main theme
    # https://github.com/chriskempson/base16#scheme-repositories
    base16-atelier = {
      url = github:atelierbram/base16-atelier-schemes;
      flake = false;
    };

    base16-unclaimed = {
      url = github:chriskempson/base16-unclaimed-schemes;
      flake = false;
    };

    # Theme templates
    # https://github.com/chriskempson/base16#template-repositories
    base16-shell = {
      url = github:chriskempson/base16-shell;
      flake = false;
    };

    base16-fish-shell = {
      url = github:FabioAntunes/base16-fish-shell;
      flake = false;
    };

    base16-alacritty = {
      url = github:aarowill/base16-alacritty;
      flake = false;
    };

    base16-mako = {
      url = github:Eluminae/base16-mako;
      flake = false;
    };

    base16-wofi = {
      url = https://git.sr.ht/~knezi/base16-wofi/archive/v1.0.tar.gz;
      flake = false;
    };

    base16-waybar = {
      url = github:mnussbaum/base16-waybar;
      flake = false;
    };

    base16-sway = {
      url = github:rkubosz/base16-sway;
      flake = false;
    };

    base16-gtk = {
      url = github:Misterio77/base16-gtk-flatcolor;
      flake = false;
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    with nixpkgs.lib;
    with builtins;

    let
      optionalModule = (optionalFile: args: (optionalAttrs (pathExists optionalFile) (import optionalFile args)));

      # Returns an array of the hostnames under `./hosts/`
      hosts = attrNames (filterAttrs (n: v: v == "directory") (readDir ./hosts));

      hostFile = hostName: fileName: ./hosts/${hostName}/${ fileName };
      hostFileExists = hostName: fileName: pathExists (hostFile hostName fileName);

      # Recursively merge an attribute set. If all elements at a path are:
      #   attrs: recursively apply
      #   lists: flatten into a unique list
      #   mixed: merge into a unique list
      recursiveAttrsToList =
        let
          f = zipAttrsWith (name: values:
            if all isAttrs values then f values
            else if all isList values then unique (concatLists values)
            else unique values
          );
        in
        f;

      # A combined AttrSet of all host exports
      # TODO: pretty redundant
      hostExport = hostName: optionalAttrs (hostFileExists hostName "exports.nix") (import (hostFile hostName "exports.nix"));
      hostExportAttr = hostName: nameValuePair hostName (hostExport hostName);
      exports = listToAttrs (forEach hosts hostExportAttr);
      mergedExports = recursiveAttrsToList (forEach hosts hostExport);

      hostModules = hostName: [
        # Host-specific config
        ./hosts/${hostName}

        { networking.hostName = hostName; }
      ];

      defaultModules = (hostName: extraSettings: [
        # Custom system modules
        ./sys

        # Home-manager module
        # https://nix-community.github.io/home-manager/index.html#sec-install-nixos-module
        inputs.home-manager.nixosModules.home-manager

        # Nix User repo
        inputs.nur.nixosModules.nur

        # Docker-compose in Nix
        inputs.arion.nixosModules.arion

        # Nixpkgs overlays
        ({ config, inputs, ... }: {
          nixpkgs = {
            config.allowUnfree = true;

            overlays = [
              (final: prev: {
                # Makes "pkgs.unstable" available in configuration.nix
                unstable = import inputs.nixpkgs-unstable {
                  system = prev.system;
                  config.allowUnfree = true;
                };

                # Makes "pkgs.unstable" available in configuration.nix
                kernel = import inputs.nixpkgs-kernel {
                  system = prev.system;
                  config.allowUnfree = true;
                };
              })
            ];
          };
        })

        # Home-manager configuration
        ({ config, inputs, ... }: {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "home-manager-backup";
            users.david = import ./home;
            users.root.home.stateVersion = "22.11";

            sharedModules = [{
              # Add nix environment variables to home manager. This is necessary for NIX_LD
              # to work on non-interactive login (e.g., running vscode remotely)
              home.sessionVariables = (mapAttrs (n: v: (mkOptionDefault v)) config.environment.variables);
            }];

            # Pass extra arguments to home.nix
            extraSpecialArgs = {
              inherit inputs;
              sysCfg = config.sys;
              nur = config.nur;
            };
          };
        })

        # Passed-in module
        extraSettings
      ] ++ (hostModules hostName));

      # Pass extra arguments to modules
      specialArgs = {
        inputs = inputs // {
          inherit exports hostFile mergedExports;
        };
      };
    in
    {
      nixosConfigurations = with nixpkgs.lib; rec {
        pavil = nixosSystem {
          inherit specialArgs;

          system = "x86_64-linux";
          modules = defaultModules "pavil" { };
        };

        nebula = nixosSystem {
          inherit specialArgs;

          system = "x86_64-linux";
          modules = defaultModules "nebula" { };
        };

        ace = nixosSystem {
          inherit specialArgs;

          system = "x86_64-linux";
          modules = defaultModules "ace" { };
          #modules = defaultModules "ace" ./hosts/portable/partition.nix;
        };

        nib = nixosSystem {
          inherit specialArgs;

          system = "x86_64-linux";
          modules = defaultModules "nib" { };
        };

        cuttlefish = nixosSystem {
          inherit specialArgs;

          system = "x86_64-linux";
          modules = defaultModules "cuttlefish" { };
        };

        # https://mobile.nixos.org/devices/motorola-potter.html
        # - Test with: nix eval "/etc/nixos#nixosConfigurations.moto.config.system.build.toplevel.drvPath"
        # - Build with: nixos-rebuild build --flake path:///etc/nixos#moto
        moto = nixosSystem {
          inherit specialArgs;

          system = "aarch64-linux";
          modules = (defaultModules "moto" { }) ++ [
            (import "${inputs.mobile-nixos}/lib/configuration.nix" { device = "motorola-potter"; })
          ];
        };

        # Build with: `nix build 'path:.#nixosConfigurations.moto-image'`
        # Impure needed to access host paths without putting in the nix store
        moto-image = moto.config.mobile.outputs.android.android-fastboot-images;

        rpi3 = nixosSystem {
          inherit specialArgs;

          system = "aarch64-linux";
          modules = (defaultModules "rpi3" { }) ++ [
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          ];
        };

        # Build with: `nix build --impure 'path:.#nixosConfigurations.rpi3-image'`
        # Impure needed to access host paths without putting in the nix store
        rpi3-image = rpi3.config.system.build.sdImage;

        # Portable, can be used as a bootstrap image
        portable-i686 = nixosSystem {
          inherit specialArgs;

          system = "i686-linux";
          modules = defaultModules "portable" { };
        };

        portable-x86_64 = nixosSystem {
          inherit specialArgs;

          system = "x86_64-linux";
          modules = defaultModules "portable" { };
        };

        portable = nixosSystem {
          inherit specialArgs;

          system = "x86_64-linux";
          modules = defaultModules "portable" { };
        };

        portable-aarch64 = nixosSystem {
          inherit specialArgs;

          system = "aarch64-linux";
          modules = defaultModules "portable" { };
        };

        drywell = nixosSystem {
          inherit specialArgs;

          system = "x86_64-linux";
          modules = defaultModules "drywell" { };
        };

        installer-test = nixosSystem {
          inherit specialArgs;

          system = "x86_64-linux";
          modules = defaultModules "installer-test" { };
        };

        # Installer test
        installer = buildSystem "installer" "x86_64-linux" [
          ({ config, ... }: {
            boot.loader = {
              grub.mirroredBoots = [
                { devices = [ "/dev/disk/by-path/virtio-pci-0000:00:04.0" ]; efiSysMountPoint = "/boot/efi0"; path = "/boot/efi0/EFI"; }
                { devices = [ "/dev/disk/by-path/virtio-pci-0000:00:05.0" ]; efiSysMountPoint = "/boot/efi1"; path = "/boot/efi1/EFI"; }
                # TODO: test
                #{ devices = [ "/dev/disk/by-id/ata-QEMU_HARDDISK_QM00001" ]; efiSysMountPoint = "/boot/efi/ata-QEMU_HARDDISK_QM00001"; }
                #{ devices = [ "/dev/disk/by-id/ata-QEMU_HARDDISK_QM00002" ]; efiSysMountPoint = "/boot/efi/ata-QEMU_HARDDISK_QM00002"; }
              ];

              # TODO: only for installing
              efi.canTouchEfiVariables = false;
              grub.efiInstallAsRemovable = true;
            };

            services.qemuGuest.enable = true;
            services.spice-vdagentd.enable = true;
            boot.kernelParams = [ "nomodeset" ];
          })
        ];
      };

      packages.x86_64-linux = {
        vmware = inputs.nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          modules = [
          ];
          format = "iso";
        };
      };
    };
}
