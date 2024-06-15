# hardware/default.nix
# 	vendor specific hardware support
#   TODO : merge valve xbox and logitech
{ ... }: {
  imports = [ ./amd.nix ./intel.nix ./hid.nix ];
}
