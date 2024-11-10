# NUC
#   this is a 12th gen Intel NUC
#   it's my central Home Cloud
{ pkgs, ... }:
{

  networking.hostName = "terminus";

  # disable desktop
  nixos.desktop.enable = false;

  # filesystem :
  nixos.fileSystems = {
    enable = true;
    boot = "/dev/disk/by-partuuid/5bd1959a-7a82-4bad-868a-a601df058489";
    luks.device = "/dev/disk/by-partuuid/9e5262a8-7264-4455-8af8-f00472e8ca03";
    swap = true;
    secureboot.enable = false;
    secureboot.install = true; # remove after installation
  };

  # sleep at night :
  nixos.autowake = {
    # enable = true;
    time.sleep = "21:30";
    time.wakeup = "07:30";
  };

  # Use kmscon as the virtual console :
  services.kmscon = {
    enable = true;
    hwRender = true;
    fonts = [
      {
        name = "Source Code Pro";
        package = pkgs.source-code-pro;
      }
    ];
    extraOptions = "--term xterm-256color";
  };

  system.stateVersion = "24.05";
}
