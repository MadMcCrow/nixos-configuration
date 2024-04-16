# firefox.nix
# 	cooler firefox setup
{ pkgs, lib, ... }:
# always stay on stable
let package = pkgs.librewolf;
in {
  # fake "firefox" icon
  xdg.desktopEntries."firefox" = {
    name = "firefox";
    actions = {
      new-private-window = {
        exec = "${lib.getExe package} --private-window %U";
      };
      new-window = { exec = "${lib.getExe package} --new-window %U"; };
      profile-manager-window = {
        exec = "${lib.getExe package} --ProfileManager";
      };
    };
    categories = [ "Network" "WebBrowser" ];
    exec = "${lib.getExe package} --name firefox %U";
    genericName = "Web Browser";
    icon = "firefox";
    mimeType = [
      "text/html"
      "text/xml"
      "application/xhtml+xml"
      "application/vnd.mozilla.xul+xml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
    startupNotify = false;
    settings = { startupWMClass = "librewolf"; };
    terminal = false;
    type = "Application";
  };

  programs.librewolf = {
    enable = true;
    inherit package;
    # see https://librewolf.net/docs/settings/
    settings = {
      "browser.sessionstore.resume_from_crash" = false;
      "privacy.clearOnShutdown.history" = false;
      "identity.fxaccounts.enabled" = true;
    };
  };
}
