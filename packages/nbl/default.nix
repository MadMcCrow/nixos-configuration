# nbl/default.nix
# nbl is short for nix build log.
{
  nix,
  symlinkJoin,
  makeWrapper,
  ...
}:
symlinkJoin rec {
  name = "nbl";
  paths = [ nix ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    cp ${./nbl.sh}  $out/bin/${name}
    chmod +x $out/bin/${name}
    wrapProgram $out/bin/${name} --prefix PATH : $out/bin
  '';
  meta = {
    mainProgram = name;
  };
}
