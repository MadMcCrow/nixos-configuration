# linux/default.nix
#	Nixos on linux
#        - Desktops -> GUI desktop environment
#        - Servers  -> TUI , remote and virtualisation
#   Config can be a mix between thoses
# TODO : clean core vs command
{ ... }:
{
  imports = [
    ./core
    ./desktop
    ./extra
#   ./web
    ./vendors
  ];
}
