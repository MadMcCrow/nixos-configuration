# The KDE Theme of the steam deck.
{
  stdenvNoCC,
  zstd,
  ...
}:
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
