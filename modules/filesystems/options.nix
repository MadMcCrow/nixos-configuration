{ lib, ... }:
with lib; {
  options.nonOS.hardware.storage = {
    main = mkOption {
      type = types.str;
      description = "The main disk device to use (e.g., /dev/nvme0n1)";
    };
  };
}
