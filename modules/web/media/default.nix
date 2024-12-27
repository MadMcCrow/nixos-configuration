# media :
# media server and photo gallery
# TODO : immich or PhotoPrism or photoview
{ lib, config, ... }:
{
  options.nixos.web.media = {
    enable = lib.mkEnableOption "media servers" // {
      default = config.nixos.web.enable;
    };
  };

  imports = [ ./jellyfin.nix ];
}
