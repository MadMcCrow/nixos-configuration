# core/tools.nix
# tools for linux systems
{ pkgs, config, lib, ... }: {
  environment.systemPackages = with pkgs; [
    # partition management
    cloud-utils.guest
    parted
  ];
}
