# a plasmoid for a GNOME-ish start menu
{ stdenvNoCC, fetchurl, zstd }:
stdenvNoCC.mkDerivation {
  name = "kde-vapor-theme";
  version = "0.16-1";
  nativeBuildInputs = [ zstd ];
  src = fetchurl {
    url =
      "https://steamdeck-packages.steamos.cloud/archlinux-mirror/jupiter-rel/os/x86_64/steamdeck-kde-presets-0.16-1-any.pkg.tar.zst";
    hash = "sha256-3SOzqBUEPWLk7OIv5715whRJa3qmJaMXL1Gf/DKs5bU=";
  };
  unpackPhase = ''
    tar -xf  $src
  '';
  installPhase = ''
    mkdir -p $out/share
    cp -r ./usr/share/* $out/share/
  '';
}
