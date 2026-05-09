# vm.nix
# config for building VMs, used for testing configs
{ pkgs, nixpkgs, ... }: {
  # following configuration is added only when building VM with build-vm
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 4096; # in MiB
      cores = 4;
      host.pkgs = import nixpkgs { inherit (pkgs) system; };
    };
  };

  # spice driver
  environment.systemPackages = [ pkgs.spice-vdagent ];

  services.spice-vdagentd.enable = true;
  services.xserver.videoDrivers = [ "qxl" ];

  # broken :
  # boot.extraModulePackages = with config.boot.kernelPackages; [ virtio_vmmci ];

  # virtualisation.qemu.options = [ "-vga std" ];
  environment.variables = { QEMU_OPTS = "-m 4096 -smp 4 -enable-kvm"; };

  # gpu passthrough to the VM
  boot.initrd.kernelModules = [ "vfio_pci" "vfio" "vfio_iommu_type1" ];
}
