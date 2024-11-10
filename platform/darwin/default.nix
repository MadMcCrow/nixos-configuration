# darwin/default.nix
# 	Nix Darwin (MacOS) Specific modules
{ ... }:
{
  # import nix modules
  imports = [
    ./font.nix # custom fonts
    ./nix.nix # nixpkgs configuration
    ./shell.nix # use zsh
  ];
}
