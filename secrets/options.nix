# options.nix
# the (shared) options for secrets
# TODO : support password protected keys
{ pkgs, lib, config, ... }:
let

 # type check for paths
  pathStr =  with lib.types; 
  types.addCheck str (s: (builtins.match "(/.+)" s) == null)
  // {description = "${str.description} (with path check)";};


  # definition of a secret option
  secretOpts = { name, config, ... }: {
    options = with lib; {
      # Service to decrypt file for :
      service = mkOption {
        default = null;
        example = "nextcloud-setup";
        type = types.nullOr types.nonEmptyStr;
        description = mdDoc "service to attach the secret to";
      };

      # Encrypted file :
      encrypted = mkOption {
        example = "/nix/persist/secrets/my-secret.age";
        type = types.either pathStr types.path;
        description = mdDoc "path to encrypted file";
      };

      # decrypted file :
      decrypted = mkOption {
        example = "/etc/nextcloud/passfile";
        type = pathStr;
        description = mdDoc "path to decrypted file";
      };

      # owner of decrypted file :
      user = mkOption {
        default = "root";
        type = types.str;
        description = mdDoc "user owner of decrypted file";
      };

      group = mkOption {
        default = "root";
        type = types.str;
        description = mdDoc "group of owner of decrypted file";
      };

      # ssh keys to use for decryption
      keys = mkOption {
        example = [ "/etc/ssh/ssh_host_rsa_key" ];
        default = [ "/etc/ssh/ssh_host_rsa_key" ];
        type = types.nonEmptyListOf types.str;
        description = mdDoc "(private) key files for decrypting secrets";
      };
    };
  };
in {
  options.secrets = with lib; {
    # enable secret management
    enable = mkEnableOption (mdDoc "secrets management") // { default = true; };

    # The actual secrets
    secrets = mkOption {
      description = mdDoc "set of secrets";
      type = types.attrsOf (types.submodule secretOpts);
      default = { };
    };
  };
}
