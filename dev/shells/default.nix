# regroup all shells outputs
inputs: {
  default = import ./develop.nix inputs;
  ai = import ./ai.nix inputs;
}
