{ lib, tomlPath ? "", ... }:
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
  mkMandatoryOption = { name, type, description } :
    with lib;
    let
      check = x: lib.asserts.assertMsg (x != null) "Mandatory option `${name}` not defined in TOML configuration `${tomlPath}`";
    in
    mkOption {
      inherit description;
      type = with types; addCheck ((nullOr type) // { _mandatory = true; }) check;
      default = null;
    };
}
