# input-remapper.nix
# 	a GUI tool to remap your inputs
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let cfg = config.input.input-remapper

in {
  options.input.input-remapper = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        whether to enable ratbag a tool to customise your gaming mouse
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ input-remapper ];
    services.input-remapper = {
    enable = true;
    package = pkgs.input-remapper
    enableUdevRules = true;
    }; 

  };

}

