# wrapbash.nix
# function to easily wrap bash scripts
{
  bash,
  lib,
  makeWrapper,
  symlinkJoin,
  ...
}:
# function inputs :
(
  {
    name,
    runtimeInputs ? [ ],
  }:
  symlinkJoin {
    inherit name;
    paths = [ bash ] ++ runtimeInputs;
    buildInputs = [ makeWrapper ];
    postBuild = ''
      cp ./${name}.sh  $out/bin/${name}
      chmod +x $out/bin/${name}
      wrapProgram $out/bin/${name} --prefix PATH : $out/bin
    '';
    meta = {
      mainProgram = name;
      licence = lib.licences.mit;
    };
  }
)
