{ config, pkgs, lib, inputs, ... }:

with lib;

let
  cfg = config.sys.networking;
  hostExports = inputs.exports.${config.networking.hostName};
  user = config.sys.user;
  userHome = config.users.users.${user}.home;
  masterSshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQy90y+nSJJfVJ4f+SKyg55lhgMTp30+UKlNXWiS3/Q david@bitwarden";
in
{
  imports = [
    ./systemd.nix
  ];

  options.sys.networking = {
    enable = mkEnableOption "networking" // { default = true; };
    wireless = mkEnableOption "wireless networking" // { default = true; };
    authenticateTailscale = mkEnableOption "authenticate tailscale" // { default = false; };
  };

  config = mkIf cfg.enable {
    ########################
    ### Private SSH Keys ###
    ########################

    sops.secrets = {
      # Host
      "ssh-keys/host/ed25519" = {
        path = "/etc/ssh/ssh_host_ed25519_key";
        sopsFile = config.sys.secrets.hostSecretsFile;
      };

      "ssh-keys/host/rsa" = {
        path = "/etc/ssh/ssh_host_rsa_key";
        sopsFile = config.sys.secrets.hostSecretsFile;
      };

      # User
      "ssh-keys/${user}/ed25519" = {
        path = "${userHome}/.ssh/id_ed25519";
        owner = user;
        group = config.users.users.${user}.group;
        sopsFile = config.sys.secrets.hostSecretsFile;
      };

      wireless-env = mkIf cfg.wireless { };
    };

    # Necessary for distributed builds
    programs.ssh.extraConfig = ''
      Match user root host cuttlefish
          IdentitiesOnly yes
          IdentityFile /etc/ssh/ssh_host_ed25519_key
    '';

    #######################
    ### Public SSH Keys ###
    #######################

    home-manager.users.${user}.home.file = {
      ".ssh/id_ed25519.pub".text = hostExports.ssh-keys.${user}.ed25519;
    };

    # Host
    environment.etc = {
      "/etc/ssh/ssh_host_ed25519_key.pub" = {
        text = hostExports.ssh-keys.host.ed25519;
        mode = "0644";
      };

      "/etc/ssh/ssh_host_rsa_key.pub" = {
        text = hostExports.ssh-keys.host.rsa;
        mode = "0644";
      };
    };

    ###########################
    ### Authorized SSH Keys ###
    ###########################

    users.users.${user}.openssh.authorizedKeys.keys = flatten [
      inputs.mergedExports.ssh-keys.${user}.ed25519
      masterSshKey
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEnaSRCBwX5kziBBeMwHLoS2Pqgl2qY1EvaqT43YWPKq david@pixie"
    ];

    # Enable the ssh agent
    programs.ssh.startAgent = true;
    security.pam.enableSSHAgentAuth = true;

    ################
    ### Wireless ###
    ################

    # Configure wpg_supplicant
    networking.wireless = mkIf cfg.wireless {
      enable = true;

      # Enable wpa_gui
      userControlled.enable = true;
      environmentFile = config.sops.secrets.wireless-env.path;
      networks = {
        internet.psk = "@INTERNET@";
        "?" = {
          psk = "@INTERNET@";
          priority = 10;
        };
        iot.psk = "@IOT@";
        BossAdams.psk = "@BOSS_ADAMS@";
        "pretty fly for a wifi".psk = "@PRETTY_FLY_FOR_A_WIFI@";
        "pretty fly for a wifi-5G".psk = "@PRETTY_FLY_FOR_A_WIFI@";
        qwertyuiop.psk = "@QWERTYUIOP@";
        LGFAK.psk = "@LGFAK@";
        "gh 42".psk = "@GH_42@";
        "Menehune House & Cottage".psk = "@MENEHUNE@";
      };
    };

    ###########
    ### VPN ###
    ###########

    services.tailscale.enable = true;

    sops.secrets.tailscale-auth-key = mkIf cfg.authenticateTailscale {
      sopsFile = config.sys.secrets.hostSecretsFile;
    };

    systemd.services.tailscale-anthenticate = mkIf cfg.authenticateTailscale {
      script = ''
        tailscale up --auth-key "file:${config.sops.secrets.tailscale-auth-key.path}"
      '';
      wantedBy = [ "multi-user.target" ];
    };

    #####################
    ### Remote access ###
    #####################

    services.openssh = {
      enable = true;
      settings.PermitRootLogin = "no";
    };

    programs.mosh.enable = true;
    programs.mosh.withUtempter = false;

    ############
    ### Misc ###
    ############

    networking.fqdn = "${networking.hostName}";

    # If set to the default (true), the firewall can break some tailscale and kubernetes configs
    networking.firewall.checkReversePath = mkDefault "loose";
    networking.firewall = {
      allowPing = true;
      pingLimit = "--limit 1/second --limit-burst 10";
    };
  };
}
