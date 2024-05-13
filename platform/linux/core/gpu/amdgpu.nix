# gpu/amdgpu.nix
# 	Nixos gpu config for amd
{ config, pkgs-latest, lib, inputs, ... }: {
  config = lib.mkIf (config.nixos.gpu.vendor == "amd") {
    # RADV support
    environment.variables = { AMD_VULKAN_ICD = "RADV"; };
    services.xserver.videoDrivers = [ "amdgpu" ];
    # boot.extraModulePackages = map (x: config.boot.kernelPackages."${x}") [ "amdgpu" ];
    boot.initrd.availableKernelModules = [ "amdgpu" ];
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

    systemd.tmpfiles.rules = [
      "L+    /opt/rocm/hip   -    -    -     -    ${pkgs-latest.rocmPackages.clr}"
    ];
  };
}
