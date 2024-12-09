# media.nix
# 	packages to view, listen, etc... to medias
{ pkgs, ... }:
# SEE BAKASABLE FOR A DECENT RIPPER
# a simple CD rip command with my ASUS drive :
# cdrip =  with pkgs; writeShellApplication {
#   name = "cdrip";
#   runtimeInputs =[ whipper libmusicbrainz libdiscid sox hwinfo cdrdao flac ];
#   text = ''
#     ${lib.getbin whipper}/bin/whipper cd rip \
#     -C embed                     \ # embed cover artwork
#     -W ~/Music                   \ # work relative to the Music directory
#     -x -o 6 -r 4 -k              \ # keep going, 4 retries, offset = 6
#     -c FR -p                     \ # prefer france CDs
#   '';
# };
{
  # vlc and clementine
  home.packages = with pkgs; [ vlc ];

  # default to opening audio files in vlc
  xdg.mimeApps.defaultApplications = {
    "video/mp4" = [ "vlc.desktop" ];
    "video/quicktime" = [ "vlc.desktop" ];
    "video/x-matroska" = [ "vlc.desktop" ];
    "audio/mpeg" = [
      "clementine.desktop"
      "vlc.desktop"
    ];
    "audio/ogg" = [
      "clementine.desktop"
      "vlc.desktop"
    ];
    "audio/flac" = [
      "clementine.desktop"
      "vlc.desktop"
    ];
  };
}
