# disabled.
sources: _:
let
  nonOS = import sources.nonOS;
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
