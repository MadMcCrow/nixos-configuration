{ lib, config, ... }:
with lib; {
  options.nonOS.hardware.gpu = mkOption {
    type = types.enum [ "amd" "intel" "nvidia" "other" ];
    default = "other";
    description = "The system GPU manufacturer.";
  };

  config = {
    services.xserver.videoDrivers = mkIf (config.nonOS.hardware.gpu != "other") [ config.nonOS.hardware.gpu ];
  };
}
