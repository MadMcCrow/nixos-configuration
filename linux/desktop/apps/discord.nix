# desktop/apps/discord.nix
# 	discord app on nixos.
#   TODO: try to move to HM
{ pkgs, config, lib, ... }:
{
  # interface
  options.nixos.desktop.apps.discord = {
    enable = lib.mkEnableOption "discord" // {
      default = config.nixos.desktop.apps.enable;
    };
  };
  # discord configuration :
  config = lib.mkIf config.nixos.desktop.apps.discord.enable {
      environment.systemPackages = with pkgs; [ discord nss_latest ];
      packages = {
      unfreePackages =  [ "discord" ];
      overlays = [
        ( self: super: {
          discord = super.discord.override { withOpenASAR = true; };
        }) ];
    };
  };
}
