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

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "rtsx_pci_sdmmc"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  swapDevices = [
    {device = "/dev/disk/by-uuid/505a2e74-e6a7-44f6-b835-f1bd904acb62";}
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

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/D300-B14E";
    fsType = "vfat";
  };

  fileSystems."/home/david" = {
    device = "fast/home/david";
    fsType = "zfs";
  };

  fileSystems."/home/david/.cache" = {
    device = "fast/home/david/.cache";
    fsType = "zfs";
  };

  fileSystems."/home/david/.local/share/Steam" = {
    device = "fast/games/steam";
    fsType = "zfs";
  };

  fileSystems."/home/david/.local/share/lutris" = {
    device = "fast/games/lutris";
    fsType = "zfs";
  };

  fileSystems."/home/david/Downloads" = {
    device = "fast/home/david/Downloads";
    fsType = "zfs";
  };

  fileSystems."/home/david/code" = {
    device = "fast/home/david/code";
    fsType = "zfs";
  };

  fileSystems."/home/david/documents" = {
    device = "cuttlefish:/home/david/documents";
    fsType = "nfs4";
    options = ["noauto"];
  };

  fileSystems."/nix" = {
    device = "fast/nixos/nix";
    fsType = "zfs";
  };

  fileSystems."/root" = {
    device = "fast/home/root";
    fsType = "zfs";
  };
}
