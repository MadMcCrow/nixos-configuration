# desktop/environments/default.nix
# 	Nixos Desktop Environment
#   TODO :
#     - if KDE gets better, switch to KDE
#     - investigate cosmic
#     - either keep or remove the TV option
{ lib, ... }:
{
  options.nixos.desktop.enable = lib.mkEnableOption "NIXOS desktop experience";
  imports = [
    ./kde
    ./flatpak.nix
    ./headless.nix
    ./sddm.nix
    ./steam.nix
    ./audio.nix
  ];
}
