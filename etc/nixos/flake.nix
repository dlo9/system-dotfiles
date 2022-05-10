{
  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11-small";

    sops-nix.url = github:Mic92/sops-nix;
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs:
    let
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          system = prev.system;
          config.allowUnfree = true;
        };
      };

      common-modules = [
        # Include configuration for nixFlakes, or else everything breaks after switching
        ./configuration.nix

        # Overlays-module makes "pkgs.unstable" available in configuration.nix
        ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })

        # Secrets management
        inputs.sops-nix.nixosModules.sops

        # Custom system modules
        ./sys
      ];
    in
    {
      nixosConfigurations.pavil = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = common-modules ++ [
          # Hardware config
          ./hardware/pavil.nix

          ({ config, ... }: {
            networking = {
              hostName = "pavil";
              interfaces.wlo1.useDHCP = true;
            };

            boot.loader.grub.mirroredBoots = [
              { devices = [ "nodev" ]; efiSysMountPoint = "/boot/efi"; path = "/boot/efi/EFI"; }
            ];
          })
        ];
      };

      nixosConfigurations.ace = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = common-modules ++ [
          # Hardware config
          ./hardware/ace.nix

          ({ config, ... }: {
            networking.hostName = "ace";

            boot.loader.grub.mirroredBoots = [
              { devices = [ "/dev/disk/by-id/ata-KINGSTON_SNS4151S332G_50026B724500626D" ]; efiSysMountPoint = "/boot/efi"; path = "/boot/efi/EFI"; }
            ];
          })
        ];
      };

      nixosConfigurations.cuttlefish = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = common-modules ++ [
          # Hardware config
          ./hardware/cuttlefish.nix

          ({ config, ... }: {
            networking = {
              hostName = "cuttlefish";
              interfaces.enp2s0.useDHCP = true;
            };

            # Must load network module on boot for SSH access
            # lspci -v | grep -iA8 'network\|ethernet'
            boot.initrd.availableKernelModules = [ "r8169" ];
            boot.loader.grub.mirroredBoots = [
              # TODO: add disk for legacy boot
              { devices = [ "nodev" ]; efiSysMountPoint = "/boot/efi"; path = "/boot/efi/EFI"; }
            ];

            # GPU
            services.xserver.videoDrivers = [ "nvidia" ];
          })
        ];
      };
    };
}
