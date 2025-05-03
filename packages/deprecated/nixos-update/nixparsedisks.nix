# produces the list of TPM encrypted disks for the provided config
arg:
with builtins;
let
  disks = attrValues arg;
  encrypted = filter (x: any (s: match "tpm2-device.*" s != null) x.crypttabExtraOpts) disks;
in
concatStringsSep " " (map (x: x.device) encrypted)
