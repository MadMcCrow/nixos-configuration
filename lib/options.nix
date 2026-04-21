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

  # mkOption that takes a path
  mkPathOption = description: default:
    mkOption {
      inherit description default;
      type = types.nullOr types.path;
    };

  # mkMandatoryOption that tags the type for validation
  mkMandatoryOption = description: type:
    mkOption {
      inherit description;
      type = type // { _mandatory = true; };
    };
}
