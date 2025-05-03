# nbl/default.nix
# nbl is short for nix build log.
{
  wrapbash,
  nix,
  ...
}:
wrapbash {
  name = "nbl";
  runtimeInputs = [ nix ];
}
