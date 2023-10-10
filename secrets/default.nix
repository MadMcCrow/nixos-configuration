# secrets/default.nix
#   module for adding our secrets to the configurations
#   secrets are only used for making host variables
{ config, pkgs, lib, agenix, pycnix, self, ... }:
with builtins;
with lib;
let
  # shortcut
  cfg = config.secrets;

  # wrapped function
  mkEnableOptionDefault = desc: default:
    (mkEnableOption desc) // {
      inherit default;
    };

  # Darwin support
  isDarwin = false; # lib.strings.hasSuffix "darwin" config.platform;

  # rootFolder depends on platform :
  root = if isDarwin then ./. else /.;
  concatPath = list: root + (concatStringsSep "/" list);

  # where the machine key is stored
  hostKey = concatPath [ cfg.keyPath config.networking.hostName ];

  #
  # secrets are written as set as :
  #   { name, publicKey }
  #   with optional keys:
  #     owner, file, group
  #
  mkSecret = secret:
    {
      file = concatPath [ cfg.secretsPath "${secret.name}.age" ];
      owner = name;
      group = name;
    } // (removeAttrs secret [ "name" "publicKeys" ]);

  secretPackages = let
    # package secret script
    name = "age-gen-secret";
    nixos-age-secret = import ./age-secret.nix { inherit pkgs pycnix name; };
    nixos-update-age-secrets = let
      hostStr = toString hostKey;
      secretFile = x: toString (mkSecret x).file;
    in pkgs.writeShellScriptBin "nixos-update-age-secrets"
    (concatStringsSep "\n" (map
      (x: "${nixos-age-secret}/bin/${name} -k ${hostStr} -f ${secretFile x}")
      cfg.secrets));
  in [ nixos-update-age-secrets nixos-age-secret ];

in {
  options.secrets = {
    # path to the secret files
    secretsPath = mkOption {
      description = "path to age secret files";
      type = types.str;
      default = "/nix/persist/secrets";
    };
    # path to all the ssh keys
    keyPath = mkOption {
      description = "path to ssh keys";
      type = types.str;
      default = "/nix/persist/secrets";
    };
    secrets = mkOption {
      description = "set of secrets";
      type = types.listOf types.attrs;
      default = [ ];
    };
  };

  # darwin is not supported yet
  config = mkIf (!isDarwin) {
    # add our scripts
    environment.systemPackages = secretPackages;

    age = mkIf (pathExists hostKey) {
      secrets = listToAttrs (map (x: {
        name = x.name;
        value = mkSecret x;
      }) cfg.secrets);
      identityPaths = [ hostKey ];
    };

    # TODO : move to config directly
    # this is shared between darwin and linux
    #nixos.rebuildScripts.pre = [{
    #  name = "rebuid-secrets";
    #  pkg = age-update-secrets;
    #}];
  };
}
