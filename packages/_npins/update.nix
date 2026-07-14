# package/app helper to update all package sources
{ writeShellApplication, npins, self, ... } :
let
  dir = "packages/._npins";
in writeShellApplication
{
  name = "update-sources";
  runtimeInputs = [ npins ];
  text = ''
    npins -d ${dir} update
  '';
}
