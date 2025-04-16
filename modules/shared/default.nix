# shared/default.nix
# shared modules between linux and macos machines
{ ... }:
{
  imports = [
    ./nix.nix
    # ./ssh.nix
  ];
}
