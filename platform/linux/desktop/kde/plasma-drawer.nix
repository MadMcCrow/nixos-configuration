# a plasmoid for a GNOME-ish start menu
{ stdenv, fetchFromGitHub, libsForQt5, zip }:
stdenv.mkDerivation rec {

  pname = "plasma-drawer";
  version = "1.4";

  src = fetchFromGitHub {
    owner = "p-connor";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-oqEjClHupSJt5BE2i/qRZp1cEpf5vPfdR2qVYiX6gI0=";
  };

  nativeBuildInputs = [ libsForQt5.kpackage libsForQt5.wrapQtAppsHook zip ];

  # TODO :
  # installPhase = ''
  #   mkdir -p $out/share/plasma/plasmoids/plasma-drawer
  #   cd $src
  #   ${lib.getBin libsForQt5.kpackage}/bin/kpackagetool -i $out/share/plasma/plasmoids/plasma-drawer
  # '';
}
