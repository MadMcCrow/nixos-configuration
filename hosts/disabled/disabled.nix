# a nonOS host is just a nixOS host ;)
{
  nonOS,
  config,
  ...
}:
{
  imports = [ nonOS.nixosModules.default ];
  config = {
    network.hostname = "disabled";
    nonOS = {
      enable = false;
      storage.main = "/dev/nvme0n1";
    };
  };
}
