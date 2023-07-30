# secrets/default.nix
#   module for adding our secrets to the configurations
#   secrets are only used for making host variables
{ config, pkgs, lib, agenix, pycnix, self, ... }:
with builtins;
with lib;
let
  # shortcut
  cfg = config.secrets;

  # storage
  defaultSecretsPath="/nix/persist/secrets";

  # wrapped function
  mkEnableOptionDefault = desc : default: (mkEnableOption desc) // { inherit default;};
  concatPath = list : /. + (concatStringsSep "/" list);

  # where the machine key is stored
  hostKey = concatPath [cfg.keyPath config.networking.hostName];

  #
  # secrets are written as set as :
  #   { name, publicKey }
  #   with optional keys:
  #     owner, file, group
  #
  mkSecret = secret : {
    file  = concatPath [cfg.secretsPath "${secret.name}.age"];
    owner = name;
    group = name;
  } // (removeAttrs secret ["name" "publicKeys" ]);

  # package secret script
  # TODO : replace by script module (and python)
  gen-secret = let
  secrets = pkgs.writeText "secrets.py" (readFile ./secrets.py);
  in
  pycnix.lib."${pkgs.system}".mkCythonBin {
    name = "gen-secret";
    main = "secrets";
    modules = [ secrets ];
  };

  rebuild-secret = let
  hostStr = toString hostKey;
  secretFile = x : toString (mkSecret x).file;
  in
  pkgs.writeShellScriptBin "age-update-secrets"
  (concatStringsSep "\n" (map (x : "${gen-secret} -k ${hostStr} -f ${secretFile x}") cfg.secrets));

in
{
  options.secrets = {
    # path to the secret files
    secretsPath = mkOption {
      description = "path to age secret files"; default=defaultSecretsPath;
    };
    # path to all the ssh keys
    keyPath = mkOption {
      description = "path to ssh keys";
      default=defaultSecretsPath;
      };
    secrets = mkOption {description = "set of secrets"; type = types.listOf types.attrs; default = []; };
  };

  config = {
    # add our script
    environment.systemPackages = [ gen-secret rebuild-secret ];

    age = mkIf (pathExists hostKey) {
      secrets = listToAttrs (map (x : {name = x.name; value = mkSecret x;}) cfg.secrets);
      identityPaths = [ hostKey ];
    };

    # TODO : move to config directly
    nixos.rebuildScripts.pre = [{
      name = "rebuid-secrets";
      pkg = rebuild-secret;
    }];
  };
}
