{ lib, config, ... }:
with lib; {
  options.nonOS.hardware = {
    cpu = mkOption {
      type = types.enum [ "amd" "intel" "other" ];
      default = "other";
      description = "The system CPU manufacturer.";
    };
    gpu = mkOption {
      type = types.enum [ "amd" "intel" "nvidia" "other" ];
      default = "other";
      description = "The system GPU manufacturer.";
    };
  };

  config = {
    hardware.cpu.amd.updateMicrocode = config.nonOS.hardware.cpu == "amd";
    hardware.cpu.intel.updateMicrocode = config.nonOS.hardware.cpu == "intel";

    services.xserver.videoDrivers = mkIf (config.nonOS.hardware.gpu != "other") [ config.nonOS.hardware.gpu ];
  };
}
