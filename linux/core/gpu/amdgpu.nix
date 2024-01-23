# gpu/amdgpu.nix
# 	Nixos gpu config for amd
{ config, pkgs, lib, inputs, ... }: {
  config = lib.mkIf (config.nixos.gpu.vendor == "amd") {
    # RADV support
    environment.variables = { AMD_VULKAN_ICD = "RADV"; };
    services.xserver.videoDrivers = [ "amdgpu" ];
    # boot.extraModulePackages = map (x: config.boot.kernelPackages."${x}") [ "amdgpu" ];
    boot.initrd.availableKernelModules = [ "amdgpu" ];
    hardware.opengl = {
      extraPackages = with pkgs; [
        amdvlk
        libvdpau-va-gl
        vaapiVdpau
        rocmPackages.clr
        rocmPackages.clr.icd
      ];
      extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
    };

    systemd.tmpfiles.rules =
      [ "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}" ];
  };
}
