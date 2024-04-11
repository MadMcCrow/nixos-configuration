# core/disks.nix
#	support cd/dvd/blurays
{ pkgs, config, lib, ... }: {
  environment.systemPackages = with pkgs; [
    # librairies to support dvds
    libdvdnav
    libdvdcss
    libdvdread
    libbluray
    # get vob files from dvd
    vobcopy
    cdrtools
  ];
}
