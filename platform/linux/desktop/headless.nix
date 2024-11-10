{
  lib,
  config,
  pkgs,
  ...
}:
lib.mkIf (!config.nixos.desktop.enable) {
  system.nixos.tags = [ "Headless" ];
  services.xserver.enable = false;

  services.kmscon.enable = true;
  services.kmscon.fonts = [
    {
      name = "Source Code Pro";
      package = pkgs.source-code-pro;
    }
    {
      name = "nerdfont";
      package = pkgs.nerdfonts;
    }
  ];
}
