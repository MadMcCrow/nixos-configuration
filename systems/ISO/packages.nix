# packages I want available on my live iso :
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # as much python as one can want :
    python311Full
    python311Packages.pyparted
    python311Packages.btrfsutil
    python311Packages.sh
    python311Packages.rich
    # formatting tools :
    parted
    util-linux
    # shell tools :
    zsh
    wget
    curl
    zip
    neofetch # because its cool ;)
    lshw
    dmidecode
    pciutils
    usbutils
    psensor
    smartmontools
    lm_sensors
    policycoreutils # SELinux tool
    # git :
    git
    git-crypt
    pre-commit
    git-lfs
  ];
}
