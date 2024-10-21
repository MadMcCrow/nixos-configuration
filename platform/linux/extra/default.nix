# nixos/extra : 
# non-mandatory options that have nowhere else to live
{ lib, config, ... }:
{
  imports = [
    ./beep.nix
    ./fonts.nix
    ./vm.nix
    ./wake.nix
  ];
}
