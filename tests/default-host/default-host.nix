# a nonOS host is just a nixOS host ;)
{ nonOS, config, ... }:
{
  # nonOS exposes the flake output in its object
  imports = [ nonOS.nixosModules.default ];

  # config is a regular nixOS config
  config = {
    # regular nixOS options are valid
    network.hostname = "defaulthost";

    # nonOS is enabled by default, you can disable it
    # by setting it to false
    nonOS = {
      storage.main = "/dev/nvme0n1";
    };
  };
}
