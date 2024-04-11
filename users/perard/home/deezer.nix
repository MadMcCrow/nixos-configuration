# deezer.nix
# play deezer on desktop
{ pkgs, lib, ... }:
let

  # when updating, update version string and hash
  deezer-win = pkgs.fetchurl {
    url =
      "https://www.deezer.com/desktop/download/artifact/win32/x86/6.0.60/source/deezer-setup-6.0.60.exe";
    hash = "sha256-RjUIxCWi56A3IaGxo2vsfQ4h8JCht1RhHw/jDdd6JW8=";
  };

  deezer = pkgs.buildNpmPackage rec {
    name = "deezer-linux";
    version = "6.0.60-1";
    src = pkgs.fetchFromGitHub {
      owner = "aunetx";
      repo = name;
      rev = "v${version}";
      hash = "sha256-DKi5itmlsif8glUlQXOZpycBB3XopA7MbwZS2YJiEsQ=";
    };
    nativeBuildInputs = with pkgs; [ gnumake nodePackages.npm asar p7zip ];

    postPatch = ''
      mkdir source
      cp ${deezer-win} source/deezer-setup.exe
      cd source
      ${pkgs.p7zip}/bin/7z x -so deezer-setup.exe '$PLUGINSDIR/app-32.7z' > app-32.7z
      ${pkgs.p7zip}/bin/7z x -y -bsp0 -bso0 app-32.7z
      cd ..
      ${pkgs.asar}/bin/asar extract source/resources/app.asar app
      ${pkgs.nodePackages.npm}/bin/npm install prettier@2.8.8
      node_modules/prettier/bin-prettier.js --write "app/build/*.js"
      for f in ./patches/*
      do
        patch -p1 -dapp < $f;
      done
      head -n -1 app/package.json > tmp.txt && mv tmp.txt app/package.json
      package-append.json | tee -a app/package.json
    '';
  };

  deezer-enhanced = pkgs.stdenv.mkDerivation rec {
    name = "deezer-enhanced";
    version = "0.3.3";
    src = pkgs.fetchFromGitHub {
      owner = "duzda";
      repo = name;
      rev = "v${version}";
      hash = "sha256-8JYdDA61pcB5XCFij1lF137Z7eqpb/n9efHuMf2H8Ws=";
    };
    nativeBuildInputs = with pkgs; [ yarn ];
    buildPhase = ''
      yarn && yarn minify-webcss && yarn build:target
    '';
  };
in { home.packages = [ ]; }
