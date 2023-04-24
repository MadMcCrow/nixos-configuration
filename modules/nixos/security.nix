# nixos/security.nix
#	setting nixos and nix-store
{ pkgs, config, lib, ... }:
with builtins;
with lib;
let
  nos = config.nixos;
  cfg = nos.enhancedSecurity;

  # kernel patch for SE-linux
  # This is not compatible with building 
  # my configuration on Github-actions
  # because it fills the remote machine
  # the solution would be to build it separately 
  seLinuxKernelPatch = {
    name = "selinux-config";
    patch = null;
    extraConfig = ''
      SECURITY_SELINUX y
      SECURITY_SELINUX_BOOTPARAM n
      SECURITY_SELINUX_DISABLE n
      SECURITY_SELINUX_DEVELOP y
      SECURITY_SELINUX_AVC_STATS y
      SECURITY_SELINUX_CHECKREQPROT_VALUE 0
      DEFAULT_SECURITY_SELINUX n
    '';
  };

in {
  # interface
  options.nixos.enhancedSecurity = {
    # enable AppArmor and SELinux, this makes a slower computer
    enable = mkEnableOption (mdDoc "extra security");

    seLinux = mkEnableOption (mdDoc "Security Enhanced Linux") // {
      default = false; # toggled off for github-actions
    };
    appArmor = mkEnableOption (mdDoc "App Armor, see https://www.apparmor.net/")
      // {
        default = true;
      };
  };

  # config
  config = lib.mkIf (nos.enable && cfg.enable) {
    # policycoreutils is for load_policy, fixfiles, setfiles, setsebool, semodile, and sestatus.
    environment.systemPackages = with pkgs; [ policycoreutils ];

    # app armor :
    security.apparmor.enable = cfg.appArmor;

    # tell kernel to use SE Linux
    boot.kernelParams = if cfg.seLinux then [ "security=selinux" ] else [ ];
    # compile kernel with SE Linux support - but also support for other LSM modules
    boot.kernelPatches = if cfg.seLinux then [ seLinuxKernelPatch ] else [ ];
    # build systemd with SE Linux support so it loads policy at boot and supports file labelling
    systemd.package = pkgs.systemd.override { withSelinux = cfg.seLinux; };

  };

}
