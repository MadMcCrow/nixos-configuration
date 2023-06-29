# server/default.nix
# 	each server service is enabled in a separate sub-module
{ config, ... }: {
  # services
  imports = [ ./nextcloud.nix ];

  # interface
  options.server = {
    enable = lib.mkEnableOption (mdDoc "server services");
  };
}
