# home/applications/default.nix
# TODO : make this a shareable module (between users)
{ ... }: {
  imports = [
    ./discord
    ./deezer.nix
    ./firefox.nix
    ./games.nix
    ./multimedia.nix
    ./vscode.nix
  ];
}
