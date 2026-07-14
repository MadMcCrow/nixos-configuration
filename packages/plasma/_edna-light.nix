# The KDE Theme of the steam deck.
{
  stdenvNoCC,
  fetchurl,
  zstd,
  ...
}:
let
  url = "https://gitlab.com/jomada/Edna-Light";
in
stdenvNoCC.mkDerivation {
  pname = "plasma-vapor-theme";
  version = "0.16-1";
  nativeBuildInputs = [ zstd ];
  unpackPhase = ''
    tar -xf  $src
  '';
  installPhase = ''
    mkdir -p $out/share
    cp -r ./usr/share/* $out/share/
  '';
}
