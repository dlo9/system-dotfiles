{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    ./hardware.nix
  ];

  config = {
    networking.interfaces.wlo1.useDHCP = true;

    # Ethernet modules for remote boot login
    sys.zfs.network-modules = [ "iwlwifi" ];
    sys.zfs.initrd-wireless = true;

    boot.loader.grub.mirroredBoots = [
      { devices = [ "nodev" ]; efiSysMountPoint = "/boot/efi"; path = "/boot/efi/EFI"; }
    ];

    # Bluetooth
    services.blueman.enable = true;
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = false;
    };

    # Enable A2DP Sink: https://nixos.wiki/wiki/Bluetooth
    hardware.bluetooth.settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };

    # zrepl_switch to new bluetooth devices
    hardware.pulseaudio.extraConfig = "
      load-module module-switch-on-connect
    ";

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 8888 ];
    services.zrepl = {
      enable = true;
      settings = {
        global = {
          logging = [
            {
              type = "stdout";
              level = "warn";
              format = "human";
              time = true;
              color = true;
            }
          ];
        };

        jobs =
          let
            # listToAttrs where the value is the same for all keys
            listToUnityAttrs = list: value: listToAttrs (forEach list (key: nameValuePair key value));

            # Order filesystems by retension time. If a filesystem is in two lists,
            # the shorter lifetime takes presidence:
            #   - no-repl: up to 1 day locally
            #   - short: up to 1 week remotely
            #   - medium: up to 1 month remotely
            #   - long: up to 1 year remotely

            retentionPolicies = {
              local = [
                "pool/home/david/.cache<"
                "pool/home/david/code<"
                "pool/nixos/nix<"
              ];

              short = [ "pool/home/david/Downloads<" ];

              medium = [ ];

              long = [ "<" ];
            };

            # Turns an attrSet of { filesystem -> bool } where each filesystem in the given
            # policy is set to `true`, and each filesystem in other policies is set to `false`
            getReplicationPolicy = policy:
              let
                myFs = retentionPolicies."${policy}";
                otherFs = (flatten (mapAttrsToList (n: v: optionals (n != policy) v) retentionPolicies));
              in
              (listToUnityAttrs myFs true) // (listToUnityAttrs otherFs false);


            snapshotJob = retentionPolicy: rec {
              name = "snapshot ${retentionPolicy}-retention datasets";
              type = "snap";

              filesystems = getReplicationPolicy retentionPolicy;

              snapshotting = {
                type = "periodic";
                prefix = "zrepl_${retentionPolicy}_";
                interval = "15m";
              };

              # Keep everything, pruning will be done during replication
              pruning.keep = [
                {
                  type = "regex";
                  regex = ".*";
                }
              ];
            };
          in
          [
            {
              name = "cuttlefish replication";
              type = "source";

              serve = {
                type = "tcp";
                listen = "100.111.108.84:8888";
                listen_freebind = true;
                clients = {
                  "100.97.145.42" = "cuttlefish";
                };
              };

              # Only exclude filesystems which shouldn't replicate at all.
              # Otherwise, zrepl unnecessarily syncs the snapshots and then fails when deleting them
              filesystems = { "<" = true; } // listToUnityAttrs retentionPolicies.local false;

              send = {
                encrypted = true;
                large_blocks = true;
                compressed = true;
                embedded_data = true;
                raw = true;
              };

              snapshotting = {
                # Snapshots are done in separate jobs so that only one port is needed
                type = "manual";
              };
            }

            (snapshotJob "long")
            (snapshotJob "medium")
            (snapshotJob "short")
            (snapshotJob "local")
          ];
      };
    };
  };
}
