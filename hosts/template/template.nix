# system configuration
# Edit this file to customize your machine
{
  config,
  nonOS,
  ...
}:
{
  imports = [
    nonOS.nixosModules.default
    nonOS.nixosModules.desktop
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
