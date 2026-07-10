# hardware.nix
# CPU and GPU support
# TODO : Replace by an autodetect
{
  lib,
  config,
  nonOS,
  ...
}:
with lib;
let
os = nonOS __curPos {inherit config;};
in
{
  options = os.options {
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

  config = {
      hardware.cpu = {
        amd.updateMicrocode = os.cfg.cpu == "amd";
        intel.updateMicrocode = os.cfg.cpu == "intel";
      };
      services.xserver.videoDrivers = mkIf (os.cfg.gpu != "other") [
        cfg.gpu
      ];
    };
}
