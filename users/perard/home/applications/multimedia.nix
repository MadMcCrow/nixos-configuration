# media.nix
# 	packages to view, listen, etc... to medias
{ pkgs, pkgs-latest, config, lib, ... }:
let
  # TODO:
  # clementine is a minimal music player
  my-clementine = pkgs-latest.clementine.overrideAttrs {
    # update to latest
    src = pkgs.fetchFromGitHub {
      owner = "clementine-player";
      repo = "Clementine";
      rev = "1.4.0rc1-901-g7b678f26e";
      sha256 = "sha256-bId2CxtAb6iP4Vhhg30xA+bKicFJq+0gDPRYJyqV8XY=";
    };
    withMTP = true;
    withCD = true;
    withCloud = true;
  };

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
in {
  # vlc and clementine
  home.packages = with pkgs-latest; [ vlc ];

  # default to opening audio files in vlc
  xdg.mimeApps.defaultApplications = {
    "video/mp4" = [ "vlc.desktop" ];
    "video/quicktime" = [ "vlc.desktop" ];
    "video/x-matroska" = [ "vlc.desktop" ];
    "audio/mpeg" = [ "clementine.desktop" "vlc.desktop" ];
    "audio/ogg" = [ "clementine.desktop" "vlc.desktop" ];
    "audio/flac" = [ "clementine.desktop" "vlc.desktop" ];
  };
}
