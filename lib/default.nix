# import all our libs
{nixpkgs, ...} @ args:
with builtins;
let
  importLibs = l : a: foldl' (x: y: x // import y a) { } l;

  systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"]; # lib.platforms.linux // lib.platforms.darwin;
  perSystem =  f : a:
  let
   p = system : a // {
     pkgs = import nixpkgs { inherit system;};
   };
  in
   foldl' (x: y: x // {${y} = f p;}) {} systems;

in
( importLibs [
  ./systems
  ./options.nix
] args)
# add the "per system" libs :
// (perSystem (importLibs [
  ./python.nix
]) args)
