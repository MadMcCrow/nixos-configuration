# linux/default.nix
#	Nixos on linux
#   There are only 3 types of linux boxes :
#        - Desktops
#        - TVs
#        - Servers
#   Config can be a mix between thoses
#   Use lib.mkOverride PRIORITY VALUE; for conflicts
{ ... }: {
  imports = [ ./core ./desktop ./server ./tv ];
}
