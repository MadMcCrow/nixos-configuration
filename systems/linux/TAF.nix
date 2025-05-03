# TAF
#   previously "AF"
#   this is my main desktop PC
{
  addModules,
  config,
  nixos-hardware,
  pkgs,
  ...
}:
{
  imports =
    with nixos-hardware.nixosModules;
    [
      common-gpu-amd
      common-cpu-amd
    ]
    ++ (addModules [
      "home/linux"
      "games"
      "desktop"
    ]);

  config = {
    # stupid name here's the full list :
    # https://xcom.fandom.com/wiki/Category:XCOM_HQ_facilities_(XCOM:_Enemy_Unknown)
    networking.hostName = "workshop";

    boot = {
      extraModulePackages = with config.boot.kernelPackages; [
        # asus motherboard
        asus-wmi-sensors
        asus-ec-sensors
        nct6687d # https://github.com/Fred78290/nct6687d
        # ACPI
        # acpi_call
      ];
      # LTS version :
      kernelPackages = pkgs.linuxKernel.packages.linux_6_6; # lts
      kernelParams = [
        "nohibernate"
        "quiet"
        "idle=nomwait"
        "usbcore.autosuspend=-1"
      ];
      blacklistedKernelModules = [ "xhci_hcd" ];
    };

    # make mount depend on user : just define the dependency only for the specific user@ instance
    fileSystems."/run/media/steam" = {
      device = "nixos-pool/local/steam";
      fsType = "zfs";
      neededForBoot = false;
      options = [ "x-systemd.automount" ];
    };

    # maybe not the best name but it's XCom central, so...

    # our config :
    nixos = {
      # filesystem :
      fileSystems = {
        boot.partuuid = "TODO";
        root.partuuid = "TODO";
        swap.enable = true;
      };
    };

    games.enable = true;

    # Power Management :
    powerManagement = {
      enable = true;
      cpuFreqGovernor = "performance";
      powertop.enable = true;
    };

    system.stateVersion = "24.11";
  };
}
