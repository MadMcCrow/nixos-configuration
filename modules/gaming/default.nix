# gaming/default.nix
# 	Gaming related stuff
#	todo : implement this https://github.com/fufexan/nix-gaming
{ config, lib, pkgs, ... }: {
  imports = [ ./steam.nix ./ratbag.nix ];
}

