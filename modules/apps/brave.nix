# apps/brave.nix
# 	brave browser
#       todo : build nightly
{ pkgs, config, lib, ... }:
with builtins;
with lib;
let cfg = config.apps.brave;
in {
  options.apps.brave.enable = lib.mkOption {
    type = types.bool;
    default = false;
    description = "enable the brave browser if true";
  };
  config =
    lib.mkIf cfg.enable { environment.systemPackages = with pkgs; [ brave ]; };
}
