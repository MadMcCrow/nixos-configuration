# input-remapper.nix
# 	a GUI tool to remap your inputs
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  cfg = config.input.remapper;
  pkg = pkgs.input-remapper;
in {
  options.input.remapper = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        whether to enable ratbag a tool to customise your gaming mouse
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkg ];
    services.input-remapper = {
      enable = true;
      package = pkg;
      enableUdevRules = true;
    };
  };
}

