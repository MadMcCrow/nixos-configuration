# firefox.nix
# 	cooler firefox setup
{ pkgs-latest, lib, ... }:
let

  # TODO : build/Add firefox extensions declaratively
  buildFirefoxXpiAddon = lib.makeOverridable ({ stdenv ? pkgs-latest.stdenv
    , fetchurl ? pkgs-latest.fetchurl, pname, version, addonId, url, sha256
    , meta, ... }:
    stdenv.mkDerivation {
      name = "${pname}-${version}";
      inherit meta;
      src = fetchurl { inherit url sha256; };
      preferLocalBuild = true;
      allowSubstitutes = true;
      passthru = { inherit addonId; };
      buildCommand = ''
        dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        mkdir -p "$dst"
        install -v -m644 "$src" "$dst/${addonId}.xpi"
      '';
    });

in {
  # FIREFOX
  programs.firefox = {
    enable = true;
    package = pkgs-latest.firefox-beta;

    # profiles."default".userChrome = ''
    #     /* Hide tab bar in FF Quantum */
    #     @-moz-document url("chrome://browser/content/browser.xul") {
    #     #main-window #titlebar {
    #       overflow: hidden;
    #       transition: height 0.3s 0.3s !important;
    #     }
    #     /* Default state: Set initial height to enable animation */
    #     #main-window #titlebar { height: 3em !important; }
    #     #main-window[uidensity="touch"] #titlebar { height: 3.35em !important; }
    #     #main-window[uidensity="compact"] #titlebar { height: 2.7em !important; }
    #     /* Hidden state: Hide native tabs strip */
    #     #main-window[titlepreface*="U+200B"] #titlebar { height: 0 !important; }
    #     /* Hidden state: Fix z-index of active pinned tabs */
    #     #main-window[titlepreface*="U+200B"] #tabbrowser-tabs { z-index: 0 !important; }
    #   }
    # '';
  };
}
