# Home manager configuration
# - Manual: https://nix-community.github.io/home-manager/index.html#sec-install-nixos-module
# - Config: https://rycee.gitlab.io/home-manager/options.html
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib; {
  imports = [
    inputs.base16.homeManagerModule

    ./cli
    ./graphical
    ./options.nix
    ./vim.nix
  ];

  scheme = "${inputs.base16-atelier}/atelier-seaside.yaml";
  #scheme = "${inputs.base16-unclaimed}/apathy.yaml";

  home = {
    stateVersion = "22.05";

    sessionPath = [
      "$HOME/.local/bin"
    ];

    sessionVariables = {
      SOPS_AGE_KEY_FILE = "/var/sops-age-keys.txt";
    };
  };

  # Allow user-installed fonts
  fonts.fontconfig.enable = true;

  xdg = {
    enable = mkDefault true;

    configFile = {
      "nixpkgs/config.nix".text = ''
        {
          allowUnfree = true;
        }
      '';

      "wrap.yaml".source = mkDefault ./wrap.yaml;
    };
  };
}
