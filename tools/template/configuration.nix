# system configuration
# Edit this file to customize your machine
{ config, ... }:
let
  sources = import ./npins;
  nonOS = with builtins; getFlake (toString sources.nonOS);
in
{
  imports = [
    nonOS.nixosModules.default
    nonOS.nixosModules.desktop
    ./hardware-configuration.nix
  ];

  # config is a regular nixOS config
  config = {
    # regular nixOS options are valid
    networking.hostName = "defaulthost";

    nixpkgs.sources = sources.nixpkgs;

    # nonOS is enabled by default, you can disable it
    # by setting it to false
    nonOS = {
      storage.main = "/dev/nvme0n1";
    };
  };
}
