# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["nvme" "mpt3sas" "xhci_pci" "ahci" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  swapDevices = [
    {device = "/dev/disk/by-uuid/2bab50cb-c97d-4e2f-8ffc-0d957b1e7cbf";}
    {device = "/dev/disk/by-uuid/cfabdcdc-e671-43ee-83d9-c487e5376454";}
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  fileSystems."/" = {
    device = "fast/nixos/root";
    fsType = "zfs";
  };

  fileSystems."/boot/efi0" = {
    device = "/dev/disk/by-uuid/D10A-E7FF";
    fsType = "vfat";
  };

  fileSystems."/boot/efi1" = {
    device = "/dev/disk/by-uuid/D007-7D72";
    fsType = "vfat";
  };

  fileSystems."/home/david" = {
    device = "fast/home/david";
    fsType = "zfs";
  };

  fileSystems."/nix" = {
    device = "fast/nixos/nix";
    fsType = "zfs";
  };

  fileSystems."/root" = {
    device = "fast/home/root";
    fsType = "zfs";
  };

  fileSystems."/services/authentik/postgres" = {
    device = "fast/services/authentik/postgres";
    fsType = "zfs";
  };

  fileSystems."/services/authentik/redis" = {
    device = "fast/services/authentik/redis";
    fsType = "zfs";
  };

  fileSystems."/services/bazarr/config" = {
    device = "fast/services/bazarr/config";
    fsType = "zfs";
  };

  fileSystems."/services/calibre-server/config" = {
    device = "fast/services/calibre-server/config";
    fsType = "zfs";
  };

  fileSystems."/services/deluge/config" = {
    device = "fast/services/deluge/config";
    fsType = "zfs";
  };

  fileSystems."/services/deluge/downloads" = {
    device = "slow/services/deluge/downloads";
    fsType = "zfs";
  };

  fileSystems."/services/diun/data" = {
    device = "fast/services/diun/data";
    fsType = "zfs";
  };

  fileSystems."/services/feedpushr/data" = {
    device = "fast/services/feedpushr/data";
    fsType = "zfs";
  };

  fileSystems."/services/flame/david" = {
    device = "fast/services/flame/david";
    fsType = "zfs";
  };

  fileSystems."/services/fresh-rss/data" = {
    device = "fast/services/fresh-rss/data";
    fsType = "zfs";
  };

  fileSystems."/services/ghost/content" = {
    device = "fast/services/ghost/content";
    fsType = "zfs";
  };

  fileSystems."/services/gitea/data" = {
    device = "fast/services/gitea/data";
    fsType = "zfs";
  };

  fileSystems."/services/home-assistant/config" = {
    device = "fast/services/home-assistant/config";
    fsType = "zfs";
  };

  fileSystems."/services/home-assistant/matter" = {
    device = "fast/services/home-assistant/matter";
    fsType = "zfs";
  };

  fileSystems."/services/home-assistant/openwakeword" = {
    device = "fast/services/home-assistant/openwakeword";
    fsType = "zfs";
  };

  fileSystems."/services/home-assistant/piper" = {
    device = "fast/services/home-assistant/piper";
    fsType = "zfs";
  };

  fileSystems."/services/home-assistant/whisper" = {
    device = "fast/services/home-assistant/whisper";
    fsType = "zfs";
  };

  fileSystems."/services/immich/data" = {
    device = "fast/services/immich/data";
    fsType = "zfs";
  };

  fileSystems."/services/immich/postgres" = {
    device = "fast/services/immich/postgres";
    fsType = "zfs";
  };

  fileSystems."/services/linkding/data" = {
    device = "fast/services/linkding/data";
    fsType = "zfs";
  };

  fileSystems."/services/linkwarden/data" = {
    device = "fast/services/linkwarden/data";
    fsType = "zfs";
  };

  fileSystems."/services/linkwarden/postgres" = {
    device = "fast/services/linkwarden/postgres";
    fsType = "zfs";
  };

  fileSystems."/services/miniflux/data" = {
    device = "fast/services/miniflux/data";
    fsType = "zfs";
  };

  fileSystems."/services/miniflux/postgres" = {
    device = "fast/services/miniflux/postgres";
    fsType = "zfs";
  };

  fileSystems."/services/nextcloud/data" = {
    device = "fast/services/nextcloud/data";
    fsType = "zfs";
  };

  fileSystems."/services/nextcloud/mariadb" = {
    device = "fast/services/nextcloud/mariadb";
    fsType = "zfs";
  };

  fileSystems."/services/node-red/data" = {
    device = "fast/services/node-red/data";
    fsType = "zfs";
  };

  fileSystems."/services/overseerr/config" = {
    device = "fast/services/overseerr/config";
    fsType = "zfs";
  };

  fileSystems."/services/photoprism/config" = {
    device = "fast/services/photoprism/config";
    fsType = "zfs";
  };

  fileSystems."/services/photoprism/mariadb" = {
    device = "fast/services/photoprism/mariadb";
    fsType = "zfs";
  };

  fileSystems."/services/pihole/config" = {
    device = "fast/services/pihole/config";
    fsType = "zfs";
  };

  fileSystems."/services/plex/config" = {
    device = "fast/services/plex/config";
    fsType = "zfs";
  };

  fileSystems."/services/plextraktsync/config" = {
    device = "fast/services/plextraktsync/config";
    fsType = "zfs";
  };

  fileSystems."/services/prometheus/data" = {
    device = "fast/services/prometheus/data";
    fsType = "zfs";
  };

  fileSystems."/services/prowlarr/config" = {
    device = "fast/services/prowlarr/config";
    fsType = "zfs";
  };

  fileSystems."/services/radarr/config" = {
    device = "fast/services/radarr/config";
    fsType = "zfs";
  };

  fileSystems."/services/readarr/config" = {
    device = "fast/services/readarr/config";
    fsType = "zfs";
  };

  fileSystems."/services/readflow/postgres" = {
    device = "fast/services/readflow/postgres";
    fsType = "zfs";
  };

  fileSystems."/services/recipes/config" = {
    device = "fast/services/recipes/config";
    fsType = "zfs";
  };

  fileSystems."/services/recipes/media" = {
    device = "fast/services/recipes/media";
    fsType = "zfs";
  };

  fileSystems."/services/smartd/config" = {
    device = "fast/services/smartd/config";
    fsType = "zfs";
  };

  fileSystems."/services/sonarr/config" = {
    device = "fast/services/sonarr/config";
    fsType = "zfs";
  };

  fileSystems."/services/syncthing/config" = {
    device = "fast/services/syncthing/config";
    fsType = "zfs";
  };

  fileSystems."/slow/backup/chelsea" = {
    device = "slow/backup/chelsea";
    fsType = "zfs";
  };

  fileSystems."/slow/backup/sue-old-laptop" = {
    device = "slow/backup/sue-old-laptop";
    fsType = "zfs";
  };

  fileSystems."/slow/documents" = {
    device = "slow/documents";
    fsType = "zfs";
  };

  fileSystems."/slow/media/audio" = {
    device = "slow/media/audio";
    fsType = "zfs";
  };

  fileSystems."/slow/media/comics" = {
    device = "slow/media/comics";
    fsType = "zfs";
  };

  fileSystems."/slow/media/ebooks" = {
    device = "slow/media/ebooks";
    fsType = "zfs";
  };

  fileSystems."/slow/media/photos" = {
    device = "slow/media/photos";
    fsType = "zfs";
  };

  fileSystems."/slow/media/video/isos" = {
    device = "slow/media/video/isos";
    fsType = "zfs";
  };

  fileSystems."/slow/media/video/movies" = {
    device = "slow/media/video/movies";
    fsType = "zfs";
  };

  fileSystems."/slow/media/video/personal" = {
    device = "slow/media/video/personal";
    fsType = "zfs";
  };

  fileSystems."/slow/media/video/tv" = {
    device = "slow/media/video/tv";
    fsType = "zfs";
  };

  fileSystems."/slow/old/games" = {
    device = "slow/games";
    fsType = "zfs";
  };

  fileSystems."/slow/smb/chelsea" = {
    device = "slow/smb/chelsea";
    fsType = "zfs";
  };

  fileSystems."/var/lib/containerd" = {
    device = "fast/containerd";
    fsType = "zfs";
  };

  fileSystems."/var/lib/containerd/io.containerd.content.v1.content" = {
    device = "fast/containerd/content";
    fsType = "zfs";
  };

  fileSystems."/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs" = {
    device = "fast/containerd/snapshotter";
    fsType = "zfs";
  };

  fileSystems."/var/lib/docker" = {
    device = "fast/docker";
    fsType = "zfs";
  };

  fileSystems."/zfs" = {
    device = "fast/zfs";
    fsType = "zfs";
  };
}
