{ config, pkgs, lib, pycnix, ... }:
with builtins;
let
  cfg = config.secrets;
  # the various scripts for nixage
  nixage-scripts = import ./scripts.nix { inherit pkgs pycnix; };
  # script to generate secrets and keys based on running config
  generators =  import ./generators.nix { inherit config pkgs nixage-scripts;};

  # function to build service for secret
  mkServicePair = secretName: secretOpts : {
        partOf = lib.lists.optional (secretOpts.service != null) secretOpts.service;
        # execution
        serviceConfig = {
          # START : decrypt
          ExecStart = if cfg.tmpfs.enable then
          # decrypt to tmpfs and symlink to target
          ''
           ${nixage-scripts.applySecret}/bin/nixage-apply -s -F \
            -i ${secretOpts.encrypted} -o ${cfg.tmpfs.mountPoint}/${secretOpts.decrypted} \
            -u ${secretOpts.user} -g ${secretOpts.group}
            ln -s ${cfg.tmpfs.mountPoint}/${secretOpts.decrypted} ${secretOpts.decrypted}
          ''
          else # decrypt directly to target
          ''
            ${nixage-scripts.applySecret}/bin/nixage-apply -s -F \
            -i ${secretOpts.encrypted} -o ${secretOpts.decrypted} \
            -u ${secretOpts.user} -g ${secretOpts.group}
          '';
          # STOP : delete
          ExecStop =  if cfg.tmpfs.enable then
          # remove link and target
          ''
            rm ${secretOpts.decrypted}
            rm ${cfg.tmpfs.mountPoint}/${secretOpts.decrypted}
          ''
          else # only remove target
          ''
            rm ${secretOpts.decrypted}
          '';
        };
        # confine this service
        confinement = {
          enable = true;
          packages = [pkgs.coreutils nixage-scripts.applySecret] ++
           nixage-scripts.applySecret.buildInputs ;
        };
        # quick description
        description = "service to decrypt ${secretName}";
      };
in
{
  # options defined separately
  imports = [./options.nix ];
  
  # linux specific
  options.secrets = {
      tmpfs = {
        enable = lib.mkEnableOption "Use tmpfs for decrytion" // {default = true;};
        mountPoint = lib.mkOption {
          default = "/nix/secretfs";
          description = lib.mdDoc "path of tmpfs for secret decryption";
        };
    };
  };

 # nixos apply secrets
 config = lib.mkIf cfg.enable {

    # pkgs :
    environment.systemPackages = (attrValues nixage-scripts) 
      ++ (attrValues generators);

    # TMPFS for secrets (no write to disk !)
    fileSystems."${cfg.tmpfs.mountPoint}" = lib.mkIf cfg.tmpfs.enable {
        device = "none";
        fsType = "tmpfs";
        options = [ "mode=750" ];
    };

    # tmpfs rules to create and remove file
    #systemd.tmpfiles.rules = (map (x: "d ${dirOf x.decrypted} 0750 ${x.user} ${x.group} -") (attrValues cfg.secrets));

    # auto apply secrets service
    #systemd.services = (mapAttrs mkServicePair cfg.secrets);

  };
}
