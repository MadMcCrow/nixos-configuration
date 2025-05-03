# cli/default.nix
# module to have
{ _ }:
{
  imports = [
    ./tty.nix # better tty with kmscon
  ];
}
