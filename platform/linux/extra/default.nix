# nixos/extra : 
# non-mandatory options that have nowhere else to live
{ ... }:
{
  imports = [
    ./beep.nix
    ./fonts.nix
    ./vm.nix
    ./wake.nix
  ];
}
