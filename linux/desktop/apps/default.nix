# desktop/apps.nix
# 	userspace apps that are provided directly,
#   either because not present on home manager
#   or because the HM-configuration is lacking for them
{ pkgs, config, lib, ... }: {
  # interface
  options.nixos.desktop.apps = {
    enable = lib.mkEnableOption "system-wide apps" // {
      default = config.nixos.desktop.enable;
    };
  };

  imports = [ ./flatpak.nix ./games.nix ./discord.nix ./misc.nix ];

  #config
  config = lib.mkIf config.nixos.desktop.apps.enable { };
}
