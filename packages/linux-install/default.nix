{
  stdenv,
  python310Packages,
  fetchPypi,
  ...
}:
let

  pureluks = python310Packages.buildPythonPackage rec {
    pname = "pureluks";
    version = "0.0.2";
    format = "pyproject";
    src = fetchPypi {
      inherit version pname;
      hash = "sha256-xZEH5/wQrx/o4eEemFXyBQnio/jNC8yT43BtPCf/eqI=";
    };
    buildInputs = with python310Packages; [ hatchling ];
  };

  python-btrfs = python310Packages.buildPythonPackage rec {
    pname = "btrfs";
    version = "14.1";
    # format = "pyproject";
    src = fetchPypi {
      inherit version pname;
      hash = "";
    };
  };

in
stdenv.mkDerivation {
  #buildPythonApplication {
  pname = "linux-installer";
  version = "1.0";
  buildInputs =
    with python310Packages;
    [
      sh
      rich
    ]
    ++ [ pureluks ];
  src = ./.;
}
