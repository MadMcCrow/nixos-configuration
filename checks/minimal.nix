# a nonOS host is just a nixOS host ;)
{ self, ... } :
let
  inherit (import (self + "ostool")) template;
  sources = import ("${template}/npins");
  nonOS = with builtins; getFlake (toString sources.nonOS);
in
{
  imports = [ nonOS.nixosModules.default ];
  config = {
    networking.hostName = "minimal";
    nonOS = {
      enable = true;
      storage.main = "/dev/nvme0n1";
    };
  };
}
