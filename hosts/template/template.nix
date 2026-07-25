# system configuration
# Edit this file to customize your machine
{
  nonOS,
  config,
  ...
}:
{
  imports = [
    # default is the core of nonOS
    # other modules include :
    # desktop, server, games
    nonOS.nixosModules.default
    ./hardware-configuration.nix
  ];

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
