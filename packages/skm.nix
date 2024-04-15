# SKM is a ssh key manager written in go
# https://github.com/TimothyYe/skm
{ pkgs, ... }:
pkgs.buildGoPackage rec {
  pname = "skm";
  version = "0.8.6";

  src = fetchFromGitHub {
    owner = "TimothyYe";
    repo = pname;
    rev = "v${version}";
    hash = "";
  };

  goPackagePath = "github.com/TimothyYe/skm";

  meta = with lib; {
    description = "A cross-platform markdown web server";
    homepage = "https://github.com/TimothyYe/skm";
    changelog = "https://github.com/TimothyYe/skm/releases/v${version}";
    license = licenses.mit;
    mainProgram = "skm";
  };
}