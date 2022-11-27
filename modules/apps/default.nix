# apps/default.nix
# 	all the apps we want on our systems
{ pkgs, config, lib, ... }:
with builtins;
with lib;
let cfg = config.apps;
in {
  # interface
  options.apps.enable = mkOption {
    type = types.bool;
    default = true;
    description = ''
      add user-level apps to your system 
    '';
  };

  # config
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ git wget curl zip neofetch ];

  };
  imports = [ ./development ./web ./multimedia ./games ./graphics ];
}
