# a plasmoid for a GNOME-ish start menu
{
  stdenv,
  fetchFromGitHub,
  libsForQt5,
  zip,
  ...
}:
stdenv.mkDerivation rec {

  pname = "plasma-dittomenu";
  version = "1.4";

  src = fetchFromGitHub {
    owner = "adhec";
    repo = "dittoMenuKDE";
    rev = "ecb2f46f91102d9f7273abedcf97cf1efd5debf4";
    hash = "";
  };
  nativeBuildInputs = [
    libsForQt5.plasma-framework
    zip
  ];
  # TODO : fix this 
  installPhase = ''
    plasmapkg2 --install org.kde.plasma.dittomenu.tar.gz
  '';
}
