# deezer.nix
# play deezer on desktop
{ ... }:
let

  # when updating, update version string and hash
  # deezer-win = pkgs.fetchurl {
  #   url =
  #     "https://www.deezer.com/desktop/download/artifact/win32/x86/6.0.60/source/deezer-setup-6.0.60.exe";
  #   hash = "sha256-RjUIxCWi56A3IaGxo2vsfQ4h8JCht1RhHw/jDdd6JW8=";
  # };

  # npm ERR! code UNABLE_TO_GET_ISSUER_CERT_LOCALLY0m[0m
  # npm ERR! errno UNABLE_TO_GET_ISSUER_CERT_LOCALLY
  # npm ERR! request to https://registry.npmjs.org/prettier failed, reason: unable to get local issuer certificate
  #
  # npm ERR! Log files were not written due to an error writing to the directory: /homeless-shelter/.npm/_logs
  # npm ERR! You can rerun the command with `--loglevel=verbose` to see the logs in your terminal
  # deezer = pkgs.buildNpmPackage rec {
  #   name = "deezer-linux";
  #   version = "6.0.60-1";
  #   src = pkgs.fetchFromGitHub {
  #     owner = "aunetx";
  #     repo = name;
  #     rev = "v${version}";
  #     hash = "sha256-DKi5itmlsif8glUlQXOZpycBB3XopA7MbwZS2YJiEsQ=";
  #   };
  #   nativeBuildInputs = with pkgs; [ gnumake nodePackages.npm asar p7zip ];
  # 
  #   postPatch = ''
  #     mkdir source
  #     cp ${deezer-win} source/deezer-setup.exe
  #     cd source
  #     ${pkgs.p7zip}/bin/7z x -so deezer-setup.exe '$PLUGINSDIR/app-32.7z' > app-32.7z
  #     ${pkgs.p7zip}/bin/7z x -y -bsp0 -bso0 app-32.7z
  #     cd ..
  #     ${pkgs.asar}/bin/asar extract source/resources/app.asar app
  #     ${pkgs.nodePackages.npm}/bin/npm install prettier@2.8.8
  #     node_modules/prettier/bin-prettier.js --write "app/build/*.js"
  #     for f in ./patches/*
  #     do
  #       patch -p1 -dapp < $f;
  #     done
  #     head -n -1 app/package.json > tmp.txt && mv tmp.txt app/package.json
  #     package-append.json | tee -a app/package.json
  #   '';
  # };

in
# error An unexpected error occurred: "https://registry.yarnpkg.com/discord-rpc/-/discord-rpc-4.0.1.tgz: getaddrinfo EAI_AGAIN registry.yarnpkg.com".
# info If you think this is a bug, please open a bug report with the information provided in "/build/source/yarn-error.log".
# info Visit https://yarnpkg.com/en/docs/cli/install for documentation about this command.
# error https://codeload.github.com/devsnek/node-register-scheme/tar.gz/e7cc9a63a1f512565da44cb57316d9fb10750e17: getaddrinfo EAI_AGAIN codeload.github.com
# error https://registry.yarnpkg.com/bindings/-/bindings-1.5.0.tgz: getaddrinfo EAI_AGAIN registry.yarnpkg.com
# error https://registry.yarnpkg.com/node-addon-api/-/node-addon-api-1.7.2.tgz: getaddrinfo EAI_AGAIN registry.yarnpkg.com
# error https://registry.yarnpkg.com/file-uri-to-path/-/file-uri-to-path-1.0.0.tgz: getaddrinfo EAI_AGAIN registry.yarnpkg.com
# deezer-enhanced = pkgs.stdenv.mkDerivation rec {
#   name = "deezer-enhanced";
#   version = "0.3.3";
#   src = pkgs.fetchFromGitHub {
#     owner = "duzda";
#     repo = name;
#     rev = "v${version}";
#     hash = "sha256-8JYdDA61pcB5XCFij1lF137Z7eqpb/n9efHuMf2H8Ws=";
#   };
#   nativeBuildInputs = with pkgs; [ yarn ];
#   buildPhase = ''
#     yarn && yarn minify-webcss && yarn build:target
#   '';
# };
{
  home.packages = [ ];
}
