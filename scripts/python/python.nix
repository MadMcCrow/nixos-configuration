# Python.nix
# usage :
#   (import ./python.nix {inherit pkgs;}).mkPyFile ./script.py
# note :
#   we could use pkgs.writers.writePython3Bin instead
#   pkgs.writers.writePython3Bin "test" {} (builtins.readFile ./test.py)
{pkgs, ...} :
with builtins;
let
# python
python3 = pkgs.python310Full;
cython = pkgs.python310Packages.cython_3;
gcc = pkgs.gcc;
# makefile variables :
incdir = "${python3}/include/python3.10";
platincdir="${python3}/include/python3.10";
libdir1= "${python3}/lib";
libdir2= "${python3}/lib/python3.10/config-3.10-x86_64-linux-gnu";
pylib= "python3.10";
linkForShared = "-Xlinker -export-dynamic";
libs = "-lcrypt -ldl -L/nix/store/vjfvgq4qianhvj2paph2xsmy1hbjbarm-libxcrypt-4.4.30/lib -lm";
sysLibs = "-lm";

in
{
  mkPyScript = name : file:
      let
      nativeBuildInputs = with pkgs; [
          python310Full
          wget
          gnumake
          pkg-config
          gcc
          ];
      buildInputs = nativeBuildInputs;
      in
      pkgs.stdenv.mkDerivation
      {
        inherit name nativeBuildInputs buildInputs;
        srcs = [file];

        unpackPhase = ''
          sources=($srcs)
          cp ''${sources[0]} ./${name}.py
        '';

        # basically a copy of the makefile
        buildPhase = ''
        ${cython}/bin/cython --embed ${name}.py
        ${gcc}/bin/gcc -c ${name}.c -I${incdir} -I${platincdir}
        ${gcc}/bin/gcc -o ${name} ${name}.o -L${libdir1} -L${libdir2} -l${pylib} ${libs} ${sysLibs} ${linkForShared}
        '';

        installPhase = ''
        mkdir -p "$out/bin"
        cp ./${name} $out/bin/${name}
        '';
      };
}
