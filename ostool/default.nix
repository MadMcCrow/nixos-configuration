inputs@{
  lib,
  self,
  pkgs,
  stdenvNoCC,
  callPackage,
  runCommandWith,
  writeShellScript,
  makeWrapper,
  ...
}:
with builtins;
let
  # TODO : change this if it gets problematic
  basename = "os";

  # TODO : autocompletion for commands
  # https://just.systems/man/en/shell-completion-scripts.html
  #

  fileSource = path : lib.fileset.toSource { root = ./.; fileset = path; };

  # shared derivation args
  mkDerivation =
    args:
    let
      osversion = import (self + /lib/version.nix) inputs;
    in
    stdenvNoCC.mkDerivation (
      lib.recursiveUpdate {
        dontBuild = true;
        buildInputs = [makeWrapper];
        meta = {
          inherit (osversion) licence;
        };
        inherit (osversion) version;
      } args
    );

  # we package the shell script separately
  shellcommands = mkDerivation {
    name = "${basename}-sh";
    src = fileSource ./cmd.sh;
    installPhase = ''
      mkdir -p $out/bin
      install -m755 cmd.sh $out/bin/cmd
      wrapProgram $out/bin/cmd \
           --prefix PATH : ${
             lib.makeBinPath (with pkgs; [
               npins
               alejandra
               deadnix
               nixfmt
               git
             ]
             ++
               # not available on MacOS, but we still can run some of
               # the commands to initialize or build configs
               lib.optionals stdenv.hostPlatform.isLinux [ nixos-install-tools ])
           }
    '';
  };

  # the template config
  template = mkDerivation {
    name = "${basename}-scripts";
    src = fileSource ./template;
    installPhase = ''
      mkdir -p $out/share
      cp -rT . $out/share/template
    '';
  };

  # package environment
  envfile = mkDerivation {
    name = "${basename}-env";
    src = fileSource ./env;
    installPhase = ''
      mkdir -p $out/share
      cp -r . $out/share
      substituteInPlace $out/share/env \
        --replace-fail "./template" "${template}/share/template/" \
        --replace-fail "./cmd.sh" "${shellcommands}/bin/cmd"
    '';
  };

  # package all just recipes
  recipes = mkDerivation {
    src = filterSource
      (path: type:
        let
          name = baseNameOf path;
        in
          name == "justfile"
          || name == ".justfile"
          || match ".*\\.just" name != null
      ) ./.;
    name = "${basename}-just";
    installPhase = ''
      mkdir -p $out/share
      cp -r .  $out/share/
      substituteInPlace $out/share/justfile --replace "mod template" "# no template"
    '';
  };


in
runCommandWith
  {
    name = basename;
    derivationArgs = {
      nativeBuildInputs = [ makeWrapper ];
       meta.mainProgram = "${basename}";   # add getExe support
    };
  }
  ''
    mkdir -p $out/bin
    makeWrapper ${lib.getExe pkgs.just} $out/bin/${basename} \
      --add-flags "--justfile ${recipes}/share/justfile" \
      --add-flags "--dotenv-path ${envfile}/share/justfile" \
      --add-flags "--one"
  ''