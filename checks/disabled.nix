# disabled.
{ config, ... }:
let
  sources = import ../npins;
  nonOS = with builtins; getFlake (toString sources.nonOS);
in
{
  imports = [ nonOS.nixosModules.default ];
  config = {
    networking.hostName = "disabled";
    nonOS = {
      enable = false;
      storage.main = "/dev/nvme0n1";
    };
  };
}
