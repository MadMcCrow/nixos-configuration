# NUC
#   this is a 12th gen Intel NUC
#   it's my central Home Cloud
{ pkgs, ... }: {

  networking.hostName = "terminus";

  # HARDWARE :
  imports = with nixos-hardware.nixosModules; [
    common-gpu-intel
    common-cpu-intel
  ];

  # filesystem :
  nixos.fileSystem.enable = true;
  nixos.fileSystem.boot =
    "/dev/disk/by-partuuid/840a2fa5-c169-4150-a4eb-2da6f96f7890";
  nixos.fileSystem.luks =
    "/dev/disk/by-partuuid/d2dcb58b-3582-4828-9062-0085f770a493";
  nixos.fileSystem.swap = true;

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
    fonts = [{
      name = "Source Code Pro";
      package = pkgs.source-code-pro;
    }];
    extraOptions = "--term xterm-256color";
  };

  system.stateVersion = "24.04";
}
