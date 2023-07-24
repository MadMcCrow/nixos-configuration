# secrets/default.nix
#   module for adding our secrets to the configurations
#   secrets are only used for making host variables
{ config, pkgs, lib, agenix, ... }:
with builtins;
with lib;
let


  # shortcut
  cfg = config.secrets;
  # wrapped function
  mkEnableOptionDefault = desc : default: (mkEnableOption desc) // { inherit default;};
  hostKey = concatStringsSep "/" [cfg.keyPath config.networking.hostName];

  # simplify declaration of secret files
  mkSecret = args @ {name, ... } : rec{ file = ./. + "/${name}.age"; owner = name; group=owner; } // (removeAttrs args ["name"]);
  mkSecretList = x : {name = x.name; value = mkSecret x;};

  # package secret script
  gen-secret = pkgs.writeShellScriptBin "nixos-gen-secret" (builtins.readFile ../scripts/sh/gen-secret.sh);

in
{
  options.secrets = {
    keyPath = mkOption {description = "path to all keys"; default="/nix/persist/secrets";};
    secrets = mkOption {description = "set of secrets"; type = types.listOf types.attrs; default = []; };
  };

  config = {
    # add our script
    environment.systemPackages = [ gen-secret ];

    age = {
      secrets = listToAttrs ( map mkSecretList cfg.secrets);
      identityPaths = [ hostKey ];
    };
  };
}
