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

  # mkMandatoryOption that tags the type and provides a null default to prevent early crashes
  mkMandatoryOption = description: type: mkOption {
    inherit description;
    type = (types.nullOr type) // { _mandatory = true; };
    default = null;
  };
}
