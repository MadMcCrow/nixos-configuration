# a minimal host config that should be possible to build
sources: _:
let
  nonOS = import sources.nonOS;
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
