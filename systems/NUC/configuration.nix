# NUC
#   this is a 12th gen Intel NUC
#   it's my central Home Cloud
{ pkgs, ... }: {
  networking.hostName = "terminus";

  # HARDWARE :
  nixos.intel.gpu.enable = true;
  nixos.intel.cpu.enable = true;

  # Power Management : minimize consumption
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
    powertop.enable = true;
    scsiLinkPolicy = "min_power";
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
    fonts = [{
      name = "Source Code Pro";
      package = pkgs.source-code-pro;
    }];
    extraOptions = "--term xterm-256color";
  };

  system.stateVersion = "23.11";
}
