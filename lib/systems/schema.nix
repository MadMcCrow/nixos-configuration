{ lib, ... }: {
  options.nonOS = lib.mkOption {
    type = lib.types.submodule {
      freeformType = lib.types.attrsOf lib.types.anything;
    };
    description = "NonOS configuration root (populated from TOML)";
  };
}
