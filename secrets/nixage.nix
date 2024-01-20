# secrets/nixage.nix
# TODO :
# - Simplify config commands
# - Add back user-based encryption (with command ran as user)
{ pkgs, lib, config, pycnix, ... }:
with builtins;
let
  # imports scripts :
  scripts = import ./scripts { inherit pkgs pycnix; };

in {
  # the scripts
  inherit (scripts) keys crypt;

  # helper for ssh-key rotation
  updateKeys = pkgs.writeShellApplication {
    name = "nixage-update-keys";
    text = lib.strings.concatLines
      (map (x: "${lib.getExe scripts.keys} -K ${x}.pub -P ${x} || true")
        (lib.lists.unique
          (concatLists (map (s: s.keys) (attrValues config.secrets.secrets)))));
    runtimeInputs = [ scripts.keys ];
    meta = {
      mainProgram = "nixage-update-keys";
      licences = [ lib.licences.mit ];
      description = lib.mdDoc
        "a tool to generate/update the ssh-keys required for your secrets";
    };
  };

  # gen/update all secrets on the system
  # should only be done once by user
  # Should be moved to another module to work with Darwin
  updateSecrets = pkgs.writeShellApplication {
    name = "nixage-update-secrets";
    text = let
      # secret generator
      gen = x:
        "${lib.getExe scripts.crypt} encrypt -o ${x.encrypted} -k ${
          concatStringsSep " " (map (k: "${k}.pub") (lib.lists.unique x.keys))
        } -I -F";
      # out
    in lib.strings.concatLines (map (x:
      "${
        if pkgs.lib.strings.isStorePath x.encrypted then
          "echo 'secret is in store path, ignoring'"
        else
          "${gen x}"
      } || true ") (builtins.attrValues config.secrets.secrets));
    runtimeInputs = [ scripts.crypt ];
    meta = {
      mainProgram = "nixage-update-secrets";
      licences = [ lib.licences.mit ];
      description = lib.mdDoc
        "a tool to generate the encrypted files required for your secrets";
    };
  };
}
