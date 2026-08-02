# a nonOS host is just a nixOS host ;)
{
  nonOS,
  config,
  ...
}:
{
  imports = [ nonOS.nixosModules.default ];

  config = {
    networking.hostName = "minimal";
    nonOS = {
      storage.main = "/dev/nvme0n1";
    };
  };
}
