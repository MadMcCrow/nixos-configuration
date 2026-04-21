# filesystems/default.nix
# default module imports
{ _ }:
{
  imports = [
    ./filesystems.nix
    ./options.nix
  ];
}
