# add our nbl tool to user tools 
{ self, pkgs, ... }:
{
  home.packages = [ self.packages."${pkgs.system}".nbl ];
  # home.shellAliases = {};
}
