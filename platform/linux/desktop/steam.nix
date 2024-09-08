# steam is handled by home manager.
# this only opens the necessary firewall ports for steam
{ lib, config, ... }:
{
  # interface :
  options.nixos.desktop.steam = {
    firewall.enable = lib.mkEnableOption "open firewall for steam games" // {
      default = config.nixos.desktop.enable;
    };
  };
  # implementation
  config = lib.mkIf config.nixos.desktop.steam.firewall.enable {
    networking.firewall = {
      allowedTCPPorts = [
        27015 # remote play
        27036 # SRCDS Rcon port
      ];
      allowedUDPPorts = [ 27015 ]; # Gameplay traffic
      allowedUDPPortRanges = [
        {
          from = 27031;
          to = 27036;
        }
      ]; # remote play
    };
  };
}
