{ lib, config, ... }:
with lib; {
  options.nonOS.hardware.cpu = mkOption {
    type = types.enum [ "amd" "intel" "other" ];
    default = "other";
    description = "The system CPU manufacturer.";
  };

  config = {
    hardware.cpu.amd.updateMicrocode = config.nonOS.hardware.cpu == "amd";
    hardware.cpu.intel.updateMicrocode = config.nonOS.hardware.cpu == "intel";
  };
}
