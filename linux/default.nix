# linux/default.nix
#	Nixos on linux
#   There are only 2 types of linux boxes :
#        - Desktops -> GUI desktop environment
#        - Servers  -> TUI , remote and virtualisation
#   Config can be a mix between thoses
{ ... }: {
  # TODO server/desktop priority option
  imports = [ ./core ./desktop ./server ];
}
