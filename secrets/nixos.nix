{ config, pkgs, lib, pycnix, ... }:
with builtins;
let
  cfg = config.secrets;
  # the various scripts for nixage
  nixage-scripts = import ./scripts.nix { inherit pkgs pycnix; };

  # helper function for building :
  mkKeysStr = secret:
    concatStringsSep " " (map (k: "${k}.pub") (lib.lists.unique secret.keys));

  # gen/update all keys on the system
  # should only be done once by user
  # Should be moved to another module to work with Darwin
  nixage = {
    # the scripts
    inherit (nixage-scripts) keys crypt;

    # helper for ssh-key rotation
    updateKeys = pkgs.writeShellApplication {
      name = "nixage-update-keys";
      text = lib.strings.concatLines (map
        (x: "${lib.getExe nixage-scripts.keys} -K ${x}.pub -P ${x} || true")
        (lib.lists.unique (concatLists
          (map (s: s.keys) (builtins.attrValues config.secrets.secrets)))));
      runtimeInputs = [ nixage-scripts.keys ];
      meta = {
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
          "${lib.getExe nixage-scripts.crypt} encrypt -o ${x.encrypted} -u ${x.user} -g ${x.group} -k ${mkKeysStr x} -I";
        # out
      in lib.strings.concatLines (map (x:
        "${
          if pkgs.lib.strings.isStorePath x.encrypted then
            "echo 'secret is in store path, ignoring'"
          else
            "${gen x}"
        } || true ") (builtins.attrValues config.secrets.secrets));
      runtimeInputs = [ nixage-scripts.crypt ];
      meta = {
        licences = [ lib.licences.mit ];
        description = lib.mdDoc
          "a tool to generate the encrypted files required for your secrets";
      };
    };
  };

  # function to build service for secret
  mkServicePair = secretName: secretOpts: 
  let 
  unit = if secretOpts.service == null then "multi-user.target" else secretOpts.service;
  in
  {
    # make sure to start with unit
    wantedBy = [unit]; 
    partOf   = [unit];

    # if requires tmpfs : require mounts for tmpfs
    unitConfig = {
      RequiresMountsFor = "${cfg.tmpfs.mountPoint}";
    };

    # execution
    serviceConfig = {
      # START : decrypt
      ExecStart = if cfg.tmpfs.enable then
      # decrypt to tmpfs and symlink to target
      ''
        ${lib.getExe nixage.crypt} decrypt -s -F \
         -i ${secretOpts.encrypted} -o ${cfg.tmpfs.mountPoint}/${secretOpts.decrypted} \
         -u ${secretOpts.user} -g ${secretOpts.group} \
         -k ${mkKeysStr secretOpts}
         ln -s ${cfg.tmpfs.mountPoint}/${secretOpts.decrypted} ${secretOpts.decrypted}
      '' else # decrypt directly to target
      ''
        ${lib.getExe nixage.crypt} decrypt -s -F \
        -i ${secretOpts.encrypted} -o ${secretOpts.decrypted} \
        -u ${secretOpts.user} -g ${secretOpts.group} \
        -k ${mkKeysStr secretOpts}
      '';
      # STOP : delete
      ExecStop = if cfg.tmpfs.enable then
      # remove link and target
      ''
        rm ${secretOpts.decrypted}
        rm ${cfg.tmpfs.mountPoint}/${secretOpts.decrypted}
      '' else # only remove target
      ''
        rm ${secretOpts.decrypted}
      '';
    };
    # confine this service
    confinement = {
      enable = true;
      packages = [ pkgs.coreutils nixage.crypt ]
        ++ nixage.crypt.buildInputs;
    };
    # quick description
    description = "service to decrypt ${secretName}";
  };
in {
  # options defined separately
  imports = [ ./options.nix ];

  # linux specific
  options.secrets = {
    tmpfs = {
      enable = lib.mkEnableOption "Use tmpfs for decrytion" // {
        default = true;
      };
      mountPoint = lib.mkOption {
        default = "/nix/secretfs";
        description = lib.mdDoc "path of tmpfs for secret decryption";
      };
    };
  };

  # nixos apply secrets
  config = lib.mkIf cfg.enable {

    # pkgs :
    environment.systemPackages = (attrValues nixage);

    # TMPFS for secrets (no write to disk !)
    fileSystems."${cfg.tmpfs.mountPoint}" = lib.mkIf cfg.tmpfs.enable {
      device = "none";
      fsType = "tmpfs";
      options = [ "mode=750" ];
    };

    # tmpfs rules to create and remove file
    systemd.tmpfiles.rules =
      (map (x: "d ${dirOf x.decrypted} 0750 ${x.user} ${x.group} -")
        (attrValues cfg.secrets));

    # auto apply secrets service
    systemd.services = (mapAttrs mkServicePair cfg.secrets);

  };
}
