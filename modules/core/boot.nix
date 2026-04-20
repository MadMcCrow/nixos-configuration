{config, lib, ...} :
{

options.nonOS.secureboot = {
  enable = lib.mkEnableOption "secureboot" // {defaults = true;};

}
# implementation
config = let cfg = config.nonOS.secureboot; in {

boot = {
    initrd.systemd.enable = true;
    tmp.cleanOnBoot = true;
    loader.systemd-boot = {
      enable = lib.mkForce (!cfg.enable);
      editor = false;
      configurationLimit = 5;
    };
    lanzaboote = {
      inherit (cfg) enable;
      pkiBundle = "/etc/secureboot";
      configurationLimit = 5;
    };
    plymouth.enable = true;
    consoleLogLevel = 3;
  };
  environment.defaultPackages =  with pkgs;
  [
        sbctl
        tpm-luks
        tpm2-tss
        libfido2
  ];
}
