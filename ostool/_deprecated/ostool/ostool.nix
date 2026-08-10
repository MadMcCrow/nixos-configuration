# os/default.nix
# build the os tool
inputs@{
  lib,
  callPackage,
  stdenvNoCC,
  makeWrapper,
  deadnix,
  nixfmt,
  alejandra,
  nixos-install,
  nixos-install-tools,
  npins,
  ...
}:
with builtins;
let
  nixdeps = [
    # update machine pins
    npins
    # gen the config and install
    nixos-install
    nixos-install-tools
    # format the config
    deadnix
    alejandra
    nixfmt
  ];

  os-unwrapped = callPackage ./_unwrapped.nix inputs;
  settings = callPackage ./_settings.nix inputs;
  template = callPackage ./_template.nix inputs;
in
stdenvNoCC.mkDerivation {
  name = "ostool";
  version = "0.0";
  dontUnpack = true;
  buildInputs = [ os-unwrapped ];
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    cp ${os-unwrapped}/bin/os $out/bin/os
    wrapProgram $out/bin/os \
      --set-default OS_SETTINGS ${settings} \
      --set-default OS_TEMPLATE ${template} \
      --prefix PATH : ${lib.makeBinPath nixdeps}
  '';

  meta = {
    mainProgram = "os";
    licence = lib.licenses.mit;
  };
}
