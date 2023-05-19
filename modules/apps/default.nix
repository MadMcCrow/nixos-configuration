# apps/default.nix
# 	apps that are provided directly, either because not present on home manager
#   or because the HM-configuration is lacking for them
{ pkgs, config, lib, ... }:
with builtins;
with lib;
let cfg = config.apps;
in {
  # interface
  options.apps = {
    # enable
    enable = mkEnableOption (mdDoc "apps") // { default = true; };
    # list of packages to install
    packages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = ''
        list of nixpkgs package to install.
      '';
    };
    # list of packages Overrrides
    overrides = mkOption {
      type = types.set;
      default = { };
      description = ''
        set of package override
      '';
    };
  };
  # imports
  imports = [ ./discord.nix ./firefox.nix ./steam.nix ];

  # config
  config = lib.mkIf (cfg.enable && cfg.packages != [ ]) {
    environment.systemPackages = with pkgs;
      [ git wget curl zip neofetch ] ++ config.apps.packages;

  };

}
