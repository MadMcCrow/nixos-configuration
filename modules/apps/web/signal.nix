# apps/signal.nix
# 	signal secure messaging desktop app
{ pkgs, config, lib, unfree, ... }:
with builtins;
with lib;
let cfg = config.apps.signal;
in {
  options.apps.signal.enable = lib.mkOption {
    type = types.bool;
    default = false;
    description = "enable signal, the messaging app ";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ signald signal-desktop ];
  };
}
