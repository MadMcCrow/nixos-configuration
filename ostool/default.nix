inputs@{
  lib,
  treefmt-nix,
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

  # add a nice formatter to simplify formatting
  formatter = (treefmt-nix.lib.mkWrapper pkgs {
    programs =  {
      # all the nix formatter
      nixfmt.enable = true;
      statix.enable = true;
      deadnix.enable = false;
      alejandra.enable = true;
    };
  });

  # all scripting dependencies
  runtimeInputs =
    with pkgs;
    [
      formatter
      just
      fzf
      nix-output-monitor
      npins
      git
      fd
    ]
    ++
      # not available on MacOS, but we still can run some of
      # the commands to initialize or build configs
      (lib.optionals stdenv.hostPlatform.isLinux [
        nixos-install-tools
        nixos-rebuild
      ]);

  # TODO : autocompletion for commands
  # https://just.systems/man/en/shell-completion-scripts.html

  fileSource =
    path:
    lib.fileset.toSource {
      root = dirOf path;
      fileset = path;
    };

  # shared derivation args
  mkDerivation =
    args:
    let
      osversion = import (self + /lib/version.nix) inputs;
    in
    stdenvNoCC.mkDerivation (
      lib.recursiveUpdate {
        dontBuild = true;
        buildInputs = [ makeWrapper ];
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
           --prefix PATH : ${lib.makeBinPath runtimeInputs}
    '';
  };

  # the template config
  template = mkDerivation {
    name = "${basename}-scripts";
    src = fileSource ./template;
    installPhase = ''
      mkdir -p $out/share
      cp -r . $out/share
    '';
  };

  # package environment
  envfile = mkDerivation {
    name = "${basename}-env";
    src = fileSource ./.env;
    installPhase = ''
      mkdir -p $out/share
      # fix template and script path
      sed -i \
        -e 's|OS_TEMPLATE=.*|OS_TEMPLATE=${template}/share/template/|' \
        -e 's|OS_CMD=.*|OS_CMD=${shellcommands}/bin/cmd|' \
        -e 's|FORMATTER=.*|FORMATTER=${formatter}/bin/treefmt|' \
        .env
      cat .env
      cp -r . $out/share
    '';
  };

  # package all just recipes
  recipes = mkDerivation {
    src =fileSource ./os.just;
    name = "${basename}-just";
    installPhase = ''
      mkdir -p $out/share
      cp -r .  $out/share/
    '';
  };
in
runCommandWith
  {
    name = basename;
    derivationArgs = {
      nativeBuildInputs = [ makeWrapper ];
      meta.mainProgram = "${basename}"; # add getExe support
    };
  }
  ''
    mkdir -p $out/bin
    makeWrapper ${lib.getExe pkgs.just} $out/bin/${basename} \
      --add-flags "--justfile ${recipes}/share/os.just" \
      --add-flags "--dotenv-path ${envfile}/share/.env" \
      --add-flags "--one" \
      --prefix PATH : ${lib.makeBinPath runtimeInputs}
  ''
