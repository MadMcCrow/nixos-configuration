# secrets/generators.nix
# scripts to generate secrets and keys based on running config
# TODO : allow running for any config
{config, pkgs, nixage-scripts } :
let

concatSpace = l: builtins.concatStringsSep " " l;
concatLines = l: builtins.concatStringsSep "\n" l;

writeSecretApp = {name, pkg, func} :
pkgs.writeShellApplication {
    inherit name;
    text = (concatLines
      (map (x: "${func x}|| true") 
      (builtins.attrValues config.secrets.secrets)));
    runtimeInputs = [ pkg ];
  };

in
{
  # gen/update all keys on the system
  # should only be done once by user
  #nixage-gen-keys = writeSecretApp {
  #  pkg = nixage-scripts.genKeys;
  #  name = "nixage-gen-keys";
  #  func = x: "-K ${x}.pub -P ${x}";
  #};

  # gen/update all secrets on the system
  # should only be done once by user
  # nixage-gen-secrets = writeSecretApp {
  #   pkg = nixage-scripts.genSecret;
  #   name = "nixage-gen-secrets";
  #   #func = x: "-k ${map (t: "${t}.pub") x.keys} \
  #   #  -f ${x.encrypted} -u ${x.user} -g ${x.group} -I";
  # };
}
