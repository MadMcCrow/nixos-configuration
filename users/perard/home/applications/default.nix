# home/applications/default.nix
# TODO : make this a shareable module (between users)
{ ... }: {
  imports =
    [ ./deezer.nix ./discord.nix ./firefox.nix ./games.nix ./multimedia.nix ./vscode.nix ];
}
