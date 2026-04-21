{ lib, pkgs, config, ... }:
with lib;
let cfg = config.nonOS.security.onlykey;
in {
  options.nonOS.security.onlykey = {
    enable = mkEnableOption "OnlyKey support for login and disk unlocking";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      onlykey-cli
      onlykey-agent
      libfido2
    ];

    # Required for onlykey-cli until upstream is patched
    nixpkgs.config.permittedInsecurePackages = [ "python3.13-ecdsa-0.19.1" ];
  };
}
