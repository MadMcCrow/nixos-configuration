# apps/brave.nix
# 	brave browser
#       todo : build nightly
{ pkgs, config, lib, ... }:
with builtins;
with lib;

let
  cfg = config.apps.firefox;
  firefox-compat = if config.programs.xwayland.enable then
    pkgs.firefox-wayland
  else
    pkgs.firefox;
in {
  options.apps.firefox = {
    enable = lib.mkOption {
      type = types.bool;
      default = false;
      description = "enable the firefox browser if true";
    };
    wayland = lib.mkOption {
      type = types.bool;
      default = config.programs.xwayland.enable;
      description = "if true, use the wayland compatible version";
    };
  };
  config =
    lib.mkIf cfg.enable { environment.systemPackages = [ firefox-compat ]; };
}
