# tv/default.nix
# add this modules to
{
  imports = [
    ./kodi.nix # kodi user interface
    ./waydroid.nix # waydroid android-tv fullscreen
  ];
}
