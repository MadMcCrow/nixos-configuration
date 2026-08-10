# a nonOS host is just a nixOS host ;)
_:
let
  sources = import ../npins;
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
