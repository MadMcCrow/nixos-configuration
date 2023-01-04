# users/default.nix
# 	Each user is in a separate module
{ config, ... }:
with builtins;
with lib;
let
  cfg = config.users;
  submodules = [ ./perard.nix ./guest.nix ];
in {
  option.users.enable = mkEnableOption {
    name = mdDoc "users";
    default = true;
  };
  imports = if cfg.enable then submodules else [ ];
  users.mutableUsers = cfg.enable;
}
