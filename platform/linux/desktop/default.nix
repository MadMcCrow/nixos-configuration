# desktop/environments/default.nix
# 	Nixos Desktop Environment
#   TODO :
#     - if KDE gets better, switch to KDE
#     - investigate cosmic
#     - either keep or remove the TV option
{ lib, config, ... }:
{
  options.nixos.desktop.enable = lib.mkEnableOption "NIXOS desktop experience";
  imports = [
    ./kde
    ./flatpak.nix
    ./sddm.nix
    ./steam.nix
    ./audio.nix
  ];
  # config
  config = lib.mkIf (!config.nixos.desktop.enable) {
    system.nixos.tags = [ "Headless" ];
    services.xserver.enable = false;
  };
}
