# secrets/default.nix
#   module for adding our secrets to the configurations
#   secrets are only used for making host variables
{ config, pkgs, lib, pycnix, self, ... }:
with builtins;
let

  # shortcut
  cfg = config.secrets;

  # wrapped function
  mkEnableOptionDefault = desc: default:
    (lib.mkEnableOption desc) // {
      inherit default;
    };
  mkStringOption = desc: default:
    lib.mkOption {
      description = desc;
      type = lib.types.str;
      default = default;
    };

  concatLines = list: concatStringsSep "\n" list;
  concatPath = list: concatStringsSep "/" list;

  # Darwin support : TODO
  isDarwin = false;

  # the various scripts for nixage
  nixage-scripts = import ./scripts.nix { inherit pkgs pycnix; };

  # where the machine key is stored
  hostKey = if isDarwin then
    "/etc/ssh/ssh_host_rsa_key"
  else
    concatPath [ cfg.keyPath config.networking.hostName ];

  #
  # secrets are written as set as :
  #   { name, outpath }
  #   with optional keys:
  #     user, file, group, key
  mkSecret = { name, path, ... }@secret:
    {
      inherit path;
      file = concatPath [ cfg.secretsPath "${secret.name}.age" ];
      user = secret.name;
      group = secret.name;
      keys = [ hostKey ];
    } // secret;

   # two scripts need to reference keys
  mkKeys = s: f:
    concatStringsSep " " (map f (lib.lists.unique (mkSecret s).keys));

  # gen/update all keys on the system
  # should only be done once by user
  nixage-gen-keys = let
    pkg = nixage-scripts.genKeys;
    keys =
      lib.lists.unique (concatLists (map (s: (mkSecret s).keys) cfg.secrets));
  in pkgs.writeShellApplication {
    name = cfg.pnames.gen-keys;
    text = (concatLines (map (x: "${pkg}/bin/${pkg.name} -K ${x}.pub -P ${x}") keys));
    runtimeInputs = [ pkg ];
  };

  # gen/update all secrets on the system
  # should only be done once by user
  nixage-gen-secrets = let
    pkg = nixage-scripts.genSecret;
    file = x: (mkSecret x).file;
    user = x: toString (mkSecret x).user;
    group = x: toString (mkSecret x).group;
    keys = x: mkKeys x (s: "${s}.pub");
  in pkgs.writeShellApplication {
    name = cfg.pnames.gen-secrets;
    text = (concatLines (map (x:
      "${pkg}/bin/${pkg.name} -k ${keys x} -f ${file x} -u ${user x} -g ${group x} -I")
       cfg.secrets));
    runtimeInputs = [ pkg ];
  };

  # unpack secrets to secret path
  nixage-apply-secrets = let
    pkg = nixage-scripts.applySecret;
    input = x: (mkSecret x).file;
    output = x: (mkSecret x).path;
    # use private key
    keys = x: mkKeys x (s: "${s}");
    user = x: toString (mkSecret x).user;
    group = x: toString (mkSecret x).group;
    command = x:
      "${pkg}/bin/${pkg.name} -k ${keys x} -i ${input x} -o ${output x} -u ${
        user x
      } -g ${group x} -F -s";
  in pkgs.writeShellApplication {
    name = cfg.pnames.apply-secrets;
    text = ''
      ex=0
      ${(concatLines (map (x: "${command x} || ex=1") cfg.secrets))}
      exit $ex
    '';
    runtimeInputs = [ pkg ];
  };
  # condition for config
  enableSecrets = ((length cfg.secrets) > 0) && cfg.enable;

in {
  # interfaces
  options.secrets = {
    # enable secret management
    enable = mkEnableOptionDefault "secrets management" true;
    services.enable = mkEnableOptionDefault "secrets management" isDarwin;
    # path to the secret files
    secretsPath =
      mkStringOption "path to age secret files" "/nix/persist/secrets";
    # path to all the ssh keys
    keyPath = mkStringOption "path to ssh keys" "/nix/persist/ssh";
    # list
    secrets = lib.mkOption {
      description = "set of secrets";
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
    };
    # only those two programs will be called by the user:
    # you don't need to change this :
    pnames = {
      gen-secrets =
        mkStringOption "secrets generator package name" "nixage-gen-secrets";
      gen-keys = mkStringOption "key generator package name" "nixage-gen-keys";
      apply-secrets =
        mkStringOption "secret deployment package name" "nixage-apply-secrets";
    };
    # the apply secrets service :
    service = {
      name = mkStringOption ''
        name for the service (and package) to apply secrets
        you don't need to edit this;
      '' "nixage-secrets.service";
    };
  };

  config = lib.mkIf enableSecrets (lib.mkMerge [
    # scripts are available on Drawin, just not the services
    ({
      environment.systemPackages = [ nixage-gen-keys nixage-gen-secrets  ]; # nixage-apply-secrets is only as a service
    })
    (lib.optionalAttrs (!isDarwin) {

      systemd = {
        # create path to folders for keys
        tmpfiles.rules = (map (x: "d ${x} 0750 root root -")
          (lib.lists.unique [ cfg.secretsPath cfg.keyPath ]))
          ++ (map (x: "d ${dirOf x.path} 0750 ${x.user} ${x.group} -")
            (map mkSecret cfg.secrets));

        # auto apply secrets service
        services."${elemAt (lib.strings.splitString "." cfg.service.name) 0}" =
          {
            serviceConfig.ExecStart =
              "${nixage-apply-secrets}/bin/${nixage-apply-secrets.name}";
            description = "service to decrypt secrets";
          };
      };
    })
  ]);
}
