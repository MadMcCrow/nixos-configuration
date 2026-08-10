inputs@{
  pkgs,
  self,
  stdenvNoCC,
  writeShellScript,
  just,
  ...
}:
let

  mkjustpkgs = {name, src, extraWrapperCmd, RuntimeDependencies, datadir ? "/share/ostool"} :
    stdenvNoCC.mkDerivation {
      inherit name src;
      inherit (import (self + /lib/version.nix) inputs) version;
      dontBuild = true;
      nativeBuildInputs = [ makeWrapper ];
      installPhase = ''
        mkdir -p $out/${datadir}
        cp -r . $out/${datadir}
        mkdir -p $out/bin
        makeWrapper ${lib.getExe just} $out/bin/${name} \
           --add-flags "--working-directory $out/${datadir}"   \
           --add-flags "--justfile $out/${datadir}/.justfile" ${extraWrapperCmd}
      '';
      meta.mainProgram = "${name}";
    };
in
rec
{
  # inherit template app
  inherit  (import ./template inputs) template;

  init =  mkjustpkgs {
    name = "os-init";
    src = ./init;
    RuntimeDependencies = [ template ];
    extraWrapperCmd = ''--set OS_TEMPLATE ${template}''
  };

  install = mkjustpkgs {
    name = "os-install"
    src = ./install;
  };

  update = mkjustpkgs {
    name = "os-update";
    src = ./update;
  };
}

