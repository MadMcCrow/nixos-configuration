# graphics.nix
# define how nonOS handles GPUs (mostly AMD)
nonOS:
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with nonOS;
let
  os = mod "graphics" config;
in
{
  options = os.mkOptions { amd.enable = mkEnableOption "AMD Specific optimisations"; };

  config = os.mkConfig {
    hardware = {
      # amd specific :
      amdgpu = mkIf os.cfg.amd.enable {
        initrd.enable = mkDefault true;
        opencl.enable = true;
      };
      # enable graphics :
      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };

    environment = mkIf os.cfg.amd.enable {
      systemPackages = with pkgs; [
        lact # Linux AMDGPU Controller
        clinfo # to test opencl setup
      ];
      variables.AMD_VULKAN_ICD = "RADV"; # force use of radv
    };

    systemd = mkIf os.cfg.amd.enable {
      # enable rocm for amd gpus
      tmpfiles.rules =
        let
          rocmEnv = pkgs.symlinkJoin {
            name = "rocm-combined";
            paths = with pkgs.rocmPackages; [
              rocblas
              hipblas
              clr
            ];
          };
        in
        [ "L+    /opt/rocm   -    -    -     -    ${rocmEnv}" ];

      # enable lact daemon
      packages = with pkgs; [ lact ];
      services.lactd.wantedBy = [ "multi-user.target" ];
    };

    # force enable rocm support if amd gpu is present
    nixpkgs.config.rocmSupport = mkDefault os.cfg.amd.enable;
  };
}
