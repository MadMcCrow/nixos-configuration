{
  lib,
  config,
  nonlib,
  ...
}:
with lib;
with nonlib;
nonOS __curPos config {
  nonOptions = {
    cpu = mkOption {
      type = types.enum [
        "amd"
        "intel"
        "other"
      ];
      default = "other";
      description = "The system CPU manufacturer.";
    };
    gpu = mkOption {
      type = types.enum [
        "amd"
        "intel"
        "nvidia"
        "other"
      ];
      default = "other";
      description = "The system GPU manufacturer.";
    };
  };

  nonConfig =
    { cfg, ... }:
    {
      hardware.cpu = {
        amd.updateMicrocode = cfg.cpu == "amd";
        intel.updateMicrocode = cfg.cpu == "intel";
      };
      services.xserver.videoDrivers = mkIf (cfg.gpu != "other") [
        cfg.gpu
      ];
    };
}
