{ lib, ... }:
with lib; {
  #
  # make a boolean option, with default = true.
  #
  mkDisableOption = d: mkEnableOption d // { default = true; };

  #
  # mkStringOption that requires an input
  #
  mkNonEmptyStrOption = description: default:
    mkOption {
      inherit description default;
      type = types.nonEmptyStr;
    };
}
