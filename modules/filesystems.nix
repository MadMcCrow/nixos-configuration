# filesystem options
{config, ... } :
{

options.nonOS.fileSystems = {
  devices ={
  encrypted = mkOption {
    description = "encrypted ";
    type = lib.types.attrs;
    default = {};
  };
  other = {
  };
};
# implementation.
config = let cfg = config.nonOS.filesystem; in {
  boot = {
    initrd = {
      systemd.enable = true; # TPM2 unlock

      luks.devices = builtins.mapAttrs (n : v:
          {
            "${n}" = {
              device = "/dev/disk/by-partlabel/${v}";
              allowDiscards = true;
              bypassWorkqueues = true;
              fallbackToPassword = true;
              crypttabExtraOpts = [ "tpm2-device=auto" ];
            };
          }) cfg.devices.encrypted;
    };

    # support only what's necessary during the boot process
    supportedFilesystems = [
      "btrfs"
      "fat32"
    ];
    # clear tmp on boot
    tmp.cleanOnBoot = true;

  environment = {
    # everything needed to deal with encrypted file systems
    defaultPackages =
      with pkgs;
 [
        sbctl
        tpm-luks
        tpm2-tss
      ])
      ++ [
        libfido2
        onlykey-cli
        onlykey-agent
        openssl
        ifwifi
        networkmanager
        dnsutils
        nmap
        ltunify # logitech unifying support
      ]
      ++ (lib.lists.optionals cfg.flatpak.enable [
        libportal
        libportal-gtk3
        packagekit
      ]);
    # helps with shells in home manager :
    pathsToLink = [
      "/share/zsh"
      "/share/bash-completion"
      "/share/fish"
    ];
  };

  fileSystems =
    let
      btrfsVolume = options: {
        device = "/dev/${cfg.fileSystems.root.lvm.vgroup}/nixos";
        fsType = "btrfs";
        inherit options;
      };
    in
    (lib.attrsets.optionalAttrs cfg.fileSystems.enable {
      # /
      #   root is always tmpfs
      "/" = {
        device = "none";
        fsType = "tmpfs";
        options = [
          "defaults"
          "size=${cfg.fileSystems.tmpfsSize}"
          "mode=755"
        ];
      };
