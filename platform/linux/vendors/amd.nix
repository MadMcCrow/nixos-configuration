# gpu/amdgpu.nix
# 	Nixos gpu config for amd
{ pkgs-latest, lib, config, ... }:
let cfg = config.nixos.amd;
in {
  # interface
  options.nixos.amd = with lib; {
    cpu.enable = mkEnableOption "AMD CPU specific configuration";
    gpu.enable = mkEnableOption "AMD GPU specific configuration";
  };

  # implementation
  config = with lib;
    mkMerge [
      # CPU config
      (mkIf cfg.cpu.enable {
        hardware.enableRedistributableFirmware = true;
        hardware.cpu.amd.updateMicrocode = true;
        boot.extraModulePackages = with config.boot.kernelPackages;
          [ zenpower ];
      })
      (mkIf cfg.gpu.enable {
        # vulkan driver :
        environment.variables = { AMD_VULKAN_ICD = "RADV"; };
        services.xserver.videoDrivers = [ "amdgpu" ];

        # kernel module :
        boot.initrd.availableKernelModules = [ "amdgpu" ];
        # don't need pro kernel package :
        # boot.extraModulePackages = with config.boot.kernelPackages; [ amdgpu-pro ];

        hardware.opengl = {
          enable = true;
          extraPackages = with pkgs-latest; [
            amdvlk
            libvdpau-va-gl
            vaapiVdpau
            rocmPackages.clr
            rocmPackages.clr.icd
          ];
          extraPackages32 = with pkgs-latest; [ driversi686Linux.amdvlk ];
          driSupport = true;
          driSupport32Bit = true;
        };

        systemd.tmpfiles.rules =
          [ "L+ /opt/rocm/hip - - - - ${pkgs-latest.rocmPackages.clr}" ];
      })
    ];
}
