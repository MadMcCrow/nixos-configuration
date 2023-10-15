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
  mkStringOption = desc: default:
    mkOption {
      description = desc;
      type = types.str;
      default = default;
    };

  # Darwin support
  isDarwin = attrsets.hasAttrByPath [ "environment" "darwinConfig" ] options;

  # where the machine key is stored
  hostKey = if isDarwin then
    [ "/etc/ssh/ssh_host_rsa_key" ]
  else
    concatStringsSep "/" [ cfg.keyPath config.networking.hostName ];

  #
  # secrets are written as set as :
  #   { name, publicKey }
  #   with optional keys:
  #     owner, file, group
  #
  mkSecret = secret:
    {
      file = concatStringsSep "/" [ cfg.secretsPath "${secret.name}.age" ];
      owner = secret.name;
      group = secret.name;
    } // (removeAttrs secret [ "name" "publicKeys" ]);

  # secret updater :
  updateSecretsName = cfg.update.pname;
  updateSecrets = let
    nixage-scripts = import ./scripts.nix { inherit pkgs pycnix; };
    name = updateSecretsName;
    hostStr = toString hostKey;
    secretFile = x: toString (mkSecret x).file;
    owner = x: toString (mkSecret x).owner;
    group = x: toString (mkSecret x).group;
  in pkgs.writeShellScriptBin name (concatStringsSep "\n" (map (x: ''
    ${nixage-scripts.ageSecret}/bin/${nixage-scripts.ageSecret.name} -k ${hostStr}\
           -f ${secretFile x} -o ${owner x} -g ${owner x}'') cfg.secrets));

  # condition for config
  enableSecrets = ((!isDarwin) && ((length cfg.secrets) > 0)) && cfg.enable;
in {
  # interfaces
  options.secrets = {
    enable = mkEnableOption "secrets management" // {
      default = true;
    };
    # path to the secret files
    secretsPath =
      mkStringOption "path to age secret files" "/nix/persist/secrets";
    # path to all the ssh keys
    keyPath = mkStringOption "path to ssh keys" "/nix/persist/ssh";
    # list
    secrets = mkOption {
      description = "set of secrets";
      type = types.listOf types.attrs;
      default = [ ];
    };
    update.pname = mkStringOption
    "package name for updating the config secrets and keys"
    "nixos-update-secrets";
  };

  # darwin is not supported yet
  config = mkIf enableSecrets {
    # add our scripts
    environment = {
      systemPackages = [ updateSecrets ];
      # not necessary, but could be useful :
      persistence."${cfg.keyPath}" = { directories = [ "/etc/ssh" ]; };
    };

    # nix age
    age = mkIf (pathExists hostKey) {
      secrets = listToAttrs (map (x: {
        name = x.name;
        value = mkSecret x;
      }) cfg.secrets);
      identityPaths = [ hostKey ] ++ (map (x: getAttr "publicKeys" x)
        (filter (x: hasAttr "publicKeys" x) cfg.secrets));
    };

    # TODO : remove for
    systemd = {
      # create path to folders for keys
      tmpfiles.rules = map (x: "d ${x} 0775 root root -")
        (lists.unique [ cfg.secretsPath cfg.keyPath ]);

      services."${updateSecretsName}" = {
        serviceConfig.ExecStart = "${updateSecrets}/bin/${updateSecretsName}";
      };
    };

  };
}
