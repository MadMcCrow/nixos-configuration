# hardware/default.nix
# 	vendor specific hardware support
{ ... }:
{
  imports = [
    ./logitech.nix # gaming mices
    ./microsoft.nix # xbox gamepad
    ./valve.nix # steam controller
  ];
}
