# beep.nix
# adds a simple service that make a beep sound when the server has successfully started
{
  pkgs,
  lib,
  config,
  ...
}:
{
  # interface
  options.nixos.extra.beep.enable = lib.mkEnableOption "make some noise when we boot successfully";

  # implementation
  config = lib.mkIf config.nixos.extra.beep.enable {
    # a simple service that beeps 
    systemd.services.beep = {
      after = [ "systemd-user-sessions.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.beep}/bin/beep";
      };
    };
  };
}
