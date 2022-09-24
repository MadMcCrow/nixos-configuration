# apps/default.nix
# 	all the apps we want on our systems
{ config, pkgs }: {
  imports = [ ./base.nix ./multimedia.nix ./vscode.nix ];
}
