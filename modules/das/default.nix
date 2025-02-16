# DAS is the module responsible for Direct attached storage
{ lib, config, self, system, ... } :
{
  
  options = with lib; {
    das.device = mkOption {
      description = "block device that acts as the zfs pool";
      type = types.str;
    };
  };
  
  config = {
    # add our tools
    environment.systemPackages = [
      self.packages."${system}".tzpfms
      self.packages."${system}".fzifdso
    ];

    boot.zfs = {
      enabled = true;
      # DAS is not root !
      forceImportRoot = false;
      # no need to deviate from default
      # package = ;
    };

    services.zfs = {
      autoScrub.enable = true;
      trim.enable = true; # already enabled by default
    };

  };
} 