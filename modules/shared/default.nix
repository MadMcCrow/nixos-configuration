# common
# shared stuff between linux and darwin
{ ... }:
{
  imports = [
    ./hostname.nix
    # ./ssh.nix
  ];
}
