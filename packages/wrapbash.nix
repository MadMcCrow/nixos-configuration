# wrapbash.nix
# function to easily wrap bash scripts
{
  bash,
  lib,
  makeWrapper,
  symlinkJoin,
  system,
  ...
}:
# function inputs :
(
  {
    name,
    runtimeInputs ? [ ],
    meta ? {},
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
    # licence is the whole project licence
    # and platforms is the platform supported by all inputs
    meta = {
      mainProgram = meta.mainProgram or name;
      licence = meta.licences or lib.licences.mit;
      platforms = meta.platforms or (
      let 
      metalist = map (x : x.meta.platforms) runtimeInputs;
      in
      lib.fold (xs: xss: lib.intersectLists xss xs) (builtins.head metalist) (builtins.tail metalist));
    };
  }
)
