# gnome-extension.nix
# 	Gnome extensions from https://extensions.gnome.org/
{ config, pkgs, lib, ... }:
with builtins;
with lib;
with pkgs; {
  # build Gnome extension function
  buildGnomeExtension = {
    # Every gnome extension has a UUID. It's the name of the extension folder once unpacked
    # and can always be found in the metadata.json of every extension.
    uuid, name, pname, description,
    # extensions.gnome.org extension URL
    link,
    # Extension version numbers are integers
    version, sha256,
    # Hex-encoded string of JSON bytes
    metadata, }:

    # set derivation
    stdenv.mkDerivation {
      pname = "gnome-shell-extension-${pname}";
      version = toString version;
      src = fetchzip {
        url = "https://extensions.gnome.org/extension-data/${
            replaceStrings [ "@" ] [ "" ] uuid
          }.v${toString version}.shell-extension.zip";
        inherit sha256;
        stripRoot = false;
        # The download URL may change content over time. This is because the
        # metadata.json is automatically generated, and parts of it can be changed
        # without making a new release. We simply substitute the possibly changed fields
        # with their content from when we last updated, and thus get a deterministic output
        # hash.
        postFetch = ''
          echo "${metadata}" | base64 --decode > $out/metadata.json
        '';
      };
      dontBuild = true;
      installPhase = ''
        runHook preInstall
        mkdir -p $out/share/gnome-shell/extensions/
        cp -r -T . $out/share/gnome-shell/extensions/${uuid}
        runHook postInstall
      '';
    };
}
