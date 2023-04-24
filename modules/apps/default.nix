# apps/default.nix
# 	all the apps we want on our systems
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

    # home manager setting
    home-manager = mkOption {
      type = types.bool;
      default = false;
      description = ''
        use home manager instead of <literal>environment.systemPackages</literal>.
        not implemented yet.
      '';
    };
  };
  # imports
  imports = [ ./development ./web ./games ./graphics ];

  # config
  config = lib.mkIf (cfg.enable && cfg.packages != [ ]) {
    environment.systemPackages = with pkgs;
      [ git wget curl zip neofetch ] ++ config.apps.packages;

  };

}
