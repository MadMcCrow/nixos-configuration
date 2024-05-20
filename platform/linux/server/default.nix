# server/default.nix
# 	each server service is enabled in a separate sub-module
{ config, pkgs, lib, ... }: {
  # definitions are in another module
  imports = [ ./containers ./services ./server.nix ];
}
