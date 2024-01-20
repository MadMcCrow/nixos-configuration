# secrets/service.nix
# A tool to create your very own systemd services based on secret definitions
# TODO : use directly the user to decrypt for when decryting
{ pkgs, lib, config, nixage, ... }:
with builtins;
let
  # shortcuts
  inherit (lib) optionalString;
  cfg = config.secrets;

  # helper
  nonNullNonEmpty = s:
    if s == null then false else if s == "" then false else true;

  # make user fitting for chmown or our nixage-crypt scrypt
  mkUser = secret:
    if nonNullNonEmpty secret.user then
      concatStringsSep ":" [
        secret.user
        (optionalString (nonNullNonEmpty secret.group) secret.group)
      ]
    else
      "";

  mkPath = l: lib.strings.normalizePath (concatStringsSep "/" l);

  # where to REALLY decrypt secret
  mkTarget = secret:
    if cfg.tmpfs.enable then
      mkPath [
        cfg.tmpfs.mountPoint
        secret.user
        (hashString "md5" secret.decrypted)
      ]
    else
      secret.decrypted;

  # script to execute to clean a decrypted secret
  clean = name: secret:
    pkgs.writeShellScriptBin "clean-${name}" ''
      rm --force ${secret.decrypted} >/dev/null 2>&1
      rm --force ${mkTarget secret}  >/dev/null 2>&1
      echo "cleaned secret ${name}"
    '';

  # script to execute to decrypt a secret to a file
  decrypt = name: secret:
    pkgs.writeShellScriptBin "decrypt-${name}" ''
      ${lib.getExe (clean name secret)}

      ${lib.getExe nixage.crypt} decrypt -S -F -i ${secret.encrypted} -o ${
        mkTarget secret
      } \
      ${optionalString (nonNullNonEmpty (secret.user)) "-U ${mkUser secret}"} \
      -k ${concatStringsSep " " (lib.lists.unique secret.keys)}

      ln -s ${mkTarget secret} ${secret.decrypted}
      chown ${secret.user}:${secret.group}  ${secret.decrypted}
    '';

  # systemd unit with which to start :
  unit = secret:
    if nonNullNonEmpty secret.service then
      secret.service
    else
      "multi-user.target";

in name: opts: {
  wantedBy = [ (unit opts) ];
  partOf = [ (unit opts) ];
  unitConfig = lib.mkIf cfg.tmpfs.enable {
    RequiresMountsFor = "${cfg.tmpfs.mountPoint}";
  };

  # execution
  serviceConfig = {
    Type = "simple";
    RemainAfterExit = false; # only for testing purposes
    User = "root"; # root is the one decrypting
    ExecStart = "${lib.getExe (decrypt name opts)}";
    ExecStop = "${lib.getExe (clean name opts)}";
  };
  # quick description
  description = "service to decrypt ${name}";
}
