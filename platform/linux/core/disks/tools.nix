# core/disks/tools.nix
# tools for managing disks and partitions
#     - grow/shrink partitions
#	    - support cd/dvd/blurays
{ pkgs, config, lib, ... }: {
  environment.systemPackages = with pkgs; [
    # partition management
    cloud-utils.guest
    parted
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
