# users/default.nix
# 	Each user is in a separate module
{ config, lib, ... }:
with builtins;
with lib;
let
  cfg = config.users;
  submodules = [ ./perard.nix ./guest.nix ];
in {
  options.users.enable = mkEnableOption (mdDoc "users") // { default = true; };
  imports = submodules;
  config.users.mutableUsers = cfg.enable;
}
