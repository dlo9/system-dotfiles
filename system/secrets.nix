{
  config,
  lib,
  inputs,
  ...
}:
with lib; {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = mkDefault "${inputs.self}/hosts/${config.networking.hostName}/secrets.yaml";
    gnupg.sshKeyPaths = mkDefault []; # Disable automatic SSH key import

    age = {
      # This file must be in the filesystems mounted within the initfs.
      # I put it in the root filesystem since that's mounted first.
      keyFile = mkDefault "/var/sops-age-keys.txt";
      sshKeyPaths = mkDefault []; # Disable automatic SSH key import
    };
  };
}
