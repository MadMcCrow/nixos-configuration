# sshram is a ssh key manager
# https://github.com/nullgemm/sshram
{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
 pname = "sshram";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "nullgemm";
    repo = pname;
    rev = "v${version}";
    hash = "";
  };

  meta = with lib; {
    description = "A cross-platform markdown web server";
    homepage = "https://github.com/nullgemm/sshram";
    changelog = "https://github.com/nullgemm/sshram/releases/v${version}";
    license = licenses.mit;
    mainProgram = "sshram";
  };
}