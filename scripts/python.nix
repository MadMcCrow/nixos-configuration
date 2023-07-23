# Python.nix
# usage :
#   (import ./python.nix {inherit pkgs;}).mkPyFile ./script.py
# note :
#   we could use pkgs.writers.writePython3Bin instead
#   pkgs.writers.writePython3Bin "test" {} (builtins.readFile ./test.py)
{pkgs, ...} :
with builtins;
let
pythonPackages = pkgs.python310Packages;
python = pkgs.python310Full;
mkPathList = base : list : concatStringsSep " " (map (x : "${base}${x}") list);

include
rec {
mkPy = name: code:
    let
    ccflags = mkPathList "-I${python}" ["/include/python3.10" "/include"];
    lpython = mkPathList "-L ${python}/lib" ["/libpython3.10.so"  "libpython3.so"];
    ldflags = concatStringsSep " " [ lpython "-lm" "-lutil" "-ldl"];
    in
    pkgs.runCommandCC name
    {
      inherit name code;
      executable = true;
      passAsFile = ["code"];
      preferLocalBuild = true;
      allowSubstitutes = false;
      nativeBuildInputs = with pythonPackages; [
        cython_3
        cppy
        genpy
        ] ++ [ python pkgs.pkg-config];
      buildInputs = [python pkgs.pkg-config];
    }
    ''
      n=$out/bin/$name
      mkdir -p "$(dirname "$n")"
      mv "$codePath" code.py
      ${pythonPackages.cython_3}/bin/cython -3 --fast-fail --embed -o code.c code.py
      $CC ${ccflags} code.c -o "$n "
    '';

mkPyFile = file :
  let
  name = elemAt (elemAt (split ".*/(.*).py" "${file}") 1) 0;
  code = readFile file;
  in
  mkPy name code;
}
