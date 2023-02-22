# core/opengl.nix
# 	make sure to enable support for opengl/vulkan and other Khronos APIs
#   todo : check relevancy for MacOS
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  nos = config.nixos;
  cfg = nos.opengl;
in {
  # interface
  options.nixos.opengl = {
    # OGL support
    enable = mkEnableOption (mdDoc ''
      OpenGL drivers. This is needed to enable OpenGL support in X11 systems,
      as well as for Wayland compositors like sway and Weston.
    '') // {
      default = true;
    };
    # AMD specificities
    amd = mkEnableOption (mdDoc
      "Advanced Micro Devices GPUs optimisations. (not implemented yet)");
  };

  # config
  config = mkIf (nos.enable && cfg.enable) {
   
    hardware.opengl = {
      enable = true;
      # direct rendering (necessary for vulkan)
      driSupport = true;
      driSupport32Bit = true;
      # extra gl driver features :
      extraPackages = with pkgs; [
        libvdpau-va-gl # vaapi
        vaapiVdpau # --  --
        rocm-opencl-icd # open-cl
        rocm-opencl-runtime # --  --
        mesa      # not sure about that, but it is definitely necessary
        amdvlk    # amdvlk for 
      ];
    };

    environment = {
      # add vulkan tools for debugging
      systemPackages = with pkgs; [vulkan-tools];
      # force the use of mesa's radv
      variables.AMD_VULKAN_ICD = "RADV";
    };

    # https://nixos.wiki/wiki/AMD_GPU#HIP
    systemd.tmpfiles.rules =
      [ "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.hip}" ];
  };
}
