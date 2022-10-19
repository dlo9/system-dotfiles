# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "mpt3sas" "isci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  swapDevices =
    [{ device = "/dev/disk/by-uuid/2bab50cb-c97d-4e2f-8ffc-0d957b1e7cbf"; }
      { device = "/dev/disk/by-uuid/cfabdcdc-e671-43ee-83d9-c487e5376454"; }];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  fileSystems."/" =
    {
      device = "fast/nixos/root";
      fsType = "zfs";
    };

  fileSystems."/boot/efi0" =
    {
      device = "/dev/disk/by-uuid/D10A-E7FF";
      fsType = "vfat";
    };

  fileSystems."/boot/efi1" =
    {
      device = "/dev/disk/by-uuid/D007-7D72";
      fsType = "vfat";
    };

  fileSystems."/boot/efi2" =
    {
      device = "/dev/disk/by-uuid/388C-755D";
      fsType = "vfat";
    };

  fileSystems."/home/david" =
    {
      device = "fast/home/david";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    {
      device = "fast/nixos/nix";
      fsType = "zfs";
    };

  fileSystems."/root" =
    {
      device = "fast/home/root";
      fsType = "zfs";
    };

  fileSystems."/slow/documents" =
    {
      device = "slow/documents";
      fsType = "zfs";
    };

  fileSystems."/slow/media/audio" =
    {
      device = "slow/media/audio";
      fsType = "zfs";
    };

  fileSystems."/slow/media/comics" =
    {
      device = "slow/media/comics";
      fsType = "zfs";
    };

  fileSystems."/slow/media/ebooks" =
    {
      device = "slow/media/ebooks";
      fsType = "zfs";
    };

  fileSystems."/slow/media/photos" =
    {
      device = "slow/media/photos";
      fsType = "zfs";
    };

  fileSystems."/slow/media/video/isos" =
    {
      device = "slow/media/video/isos";
      fsType = "zfs";
    };

  fileSystems."/slow/media/video/movies" =
    {
      device = "slow/media/video/movies";
      fsType = "zfs";
    };

  fileSystems."/slow/media/video/optimized" =
    {
      device = "slow/media/video/optimized";
      fsType = "zfs";
    };

  fileSystems."/slow/media/video/personal" =
    {
      device = "slow/media/video/personal";
      fsType = "zfs";
    };

  fileSystems."/slow/media/video/transcode" =
    {
      device = "slow/media/video/transcode";
      fsType = "zfs";
    };

  fileSystems."/slow/media/video/tv" =
    {
      device = "slow/media/video/tv";
      fsType = "zfs";
    };

  fileSystems."/slow/old/games" =
    {
      device = "slow/games";
      fsType = "zfs";
    };

  fileSystems."/slow/smb/chelsea" =
    {
      device = "slow/smb/chelsea";
      fsType = "zfs";
    };

  fileSystems."/slow/smb/chelsea-backup" =
    {
      device = "slow/smb/chelsea-backup";
      fsType = "zfs";
    };

  fileSystems."/var/lib/containerd/io.containerd.content.v1.content" =
    {
      device = "fast/kubernetes/containerd/content";
      fsType = "zfs";
    };

  fileSystems."/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs" =
    {
      device = "/dev/disk/by-uuid/bc8b3a3d-a573-4996-bc04-2a4ff209aa2f";
      fsType = "ext4";
    };

  fileSystems."/var/lib/docker/overlay2" =
    {
      device = "/dev/disk/by-uuid/f61c326a-b216-46e8-9139-75a2c9d4a1fa";
      fsType = "ext4";
    };

  fileSystems."/zfs" =
    {
      device = "fast/zfs";
      fsType = "zfs";
    };
}
