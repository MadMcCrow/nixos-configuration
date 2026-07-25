# a nonOS host is just a nixOS host ;)
{
  nonOS,
  config,
  ...
}:
{
  imports = [ nonOS.nixosModules.default ];

  config = {
    network.hostname = "minimal";
    nonOS = {
      storage.main = "/dev/nvme0n1";
    };
  };
}
