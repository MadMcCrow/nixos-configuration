# deezer.nix
# play deezer on desktop
{ pkgs, lib, ... }:
let
 deezer-enhanced = pkgs.stdenv.mkDerivation rec {
  name = "deezer-enhanced";
  version = "0.3.3";
  src = pkgs.fetchFromGitHub {
    owner = "duzda";
    repo = name;
    rev = "v${version}";
    hash = "sha256-8JYdDA61pcB5XCFij1lF137Z7eqpb/n9efHuMf2H8Ws=";
  };
  nativeBuildInputs = with pkgs; [
    yarn
  ];
  buildPhase = ''
    yarn && yarn minify-webcss && yarn build:target
  '';
 };
in
{
  home.packages = [];
}
