# we follow KDE ideology
{ config, lib, ... } :
{
  options = with lib; {
  };

config = {
  services = {
    displayManager.sddm = {
      enable = true;
      enableHidpi = true;
      autoNumlock = true;
      # this prevents issues with nvidia drivers
      wayland.enable = !(builtins.any (x: x == "nvidia") config.services.xserver.videoDrivers);
    };
  };
}
