# apps/brave.nix
# 	brave browser
#       todo : build nightly
{ pkgs, config, lib, ... }:
with builtins;
with lib;
let cfg = config.apps.firefox;
in {
  options.apps.firefox = {
    enable = lib.mkOption {
      type = types.bool;
      default = false;
      description = "enable the firefox browser if true";
    };
    wayland = lib.mkOption {
      type = types.bool;
      default = false;
      description = "if true, use the wayland compatible version";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      if cfg.wayland then [ firefox-compat ] else [ firefox ];
  };
}
