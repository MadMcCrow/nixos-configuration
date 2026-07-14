# package/app helper to update all package sources
{
  writeShellApplication,
  npins,
  rootDir ? "./",
  ...
}:
writeShellApplication {
  name = "update-sources";
  runtimeInputs = [ npins ];
  text = ''
    npins -d${rootDir}packages/_npins update
  '';
}
