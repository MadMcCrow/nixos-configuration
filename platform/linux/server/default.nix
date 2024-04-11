# server/default.nix
# 	each server service is enabled in a separate sub-module
#   TODO : use containers !
{ config, pkgs, lib, ... }:
let
  # shortcut
  cfg = config.nixos.server;
in {

  # interface
  options.nixos.server = {
    enable = lib.mkEnableOption "nixos server experience";
    adminEmail = lib.mkOption {
      description = "email to contact in case of problem";
      example = "admin@server.net";
      type = with lib.types;
        nullOr (addCheck str (s: (builtins.match "(/.+@/.)" s) != null));
    };
    hostName = lib.mkOption {
      description = "server host name";
      default = "localhost";
      type = lib.types.str;
    };
  };

  # definitions are in another module
  imports = [ ./containers ./services ./server.nix ];
}
