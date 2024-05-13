# darwin/default.nix
# 	Nix Darwin (MacOS) Specific modules
{ ... }: {
  # import nix modules
  imports = [ ./font.nix ./nix.nix ./shell.nix ./update.nix ];
}
