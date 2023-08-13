{ config, inputs, lib, pkgs, modulesPath, ... }:

{
  imports = [
    ./hardware
  ];

  sys = {
    gaming.enable = false;
  };

  services.smartd.enable = lib.mkForce false;
  virtualisation.docker.enable = lib.mkForce false;
  services.postfix.enable = lib.mkForce false;
  home-manager.users.david.services.syncthing.enable = lib.mkForce false;
}
