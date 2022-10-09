# ratbag.nix
# 	a tool to configure your gaming mouse
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let cfg = config.input.ratbag;

in {
  options.input.ratbag = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        whether to enable ratbag a tool to customise your gaming mouse
      '';
    };
  };

  config = mkIf cfg.enable {

    services.ratbagd.enable = true;
    environment.systemPackages = with pkgs; [ libratbag piper ];

  };

}

