# wip version for the OS and the tools
# In the future, I'll figure a release
# and versionning schema
{ lib, ... }: {
  version = "0.0";
  name = "nonOS";
  status = "dev";
  flake_url = "https://github.com/MadMcCrow/nonOS";
  licence = lib.licenses.mit;
}
