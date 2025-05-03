# add our nbl tool to user tools
{ self, pkgs, ... }:
{
  # for some reason this tries to build way too many things !
  # home.packages = [ self.packages."${pkgs.system}".nbl ];
  # home.shellAliases = {};
}
