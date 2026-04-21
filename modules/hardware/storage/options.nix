{ lib, ... }:
with lib; {
  options.nonOS.hardware.storage = {
    main = mkMandatoryOption "The main disk device to use (e.g., /dev/nvme0n1)."
      types.str;
  };
}
