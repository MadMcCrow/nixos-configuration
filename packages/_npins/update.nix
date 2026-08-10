# package/app helper to update all package sources
{
  writeShellApplication,
  npins,
  ...
}:
writeShellApplication {
  name = "update-sources";
  runtimeInputs = [ npins ];
  text = ''
    root=$(git rev-parse --show-toplevel)
    npins -d "$root/packages/_npins" update
  '';
}
