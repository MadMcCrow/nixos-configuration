# wrap the configuration template in a nix derivation
{self, ...} :
(self + "/tools/template")