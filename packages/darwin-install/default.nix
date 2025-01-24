# darwin-install
# basic install/update script written in bash
{ bash ,curl, lib, makeWrapper, nix, symlinkJoin,  ... }:
symlinkJoin rec {
  name = "darwin-install";
  # nix-darwin.packages.default is not needed per-se
  paths = [ bash nix curl ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    cp ${./darwin-install.sh}  $out/bin/${name}
    chmod +x $out/bin/${name}
    wrapProgram $out/bin/${name} --prefix PATH : $out/bin
  '';
  meta = {
    mainProgram = name;
    licence = lib.licences.mit;
  };
}