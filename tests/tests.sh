# test minimal config
nix eval  .#lib.mkSystem --apply "f: f ./minimal.toml"
# test default config
nix eval  .#lib.mkSystem --apply "f: f ./default_host.toml"
