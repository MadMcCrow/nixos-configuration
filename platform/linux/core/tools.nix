# core/tools.nix
# tools for linux systems
{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # partition management
    cloud-utils.guest
    parted
  ];
}
