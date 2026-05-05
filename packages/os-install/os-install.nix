# packages/os-update.nix
# Build os-update as a Nix package using buildPythonApplication

{ pkgs }:

pkgs.python311Packages.buildPythonApplication {
  pname = "os-update";
  version = "0.1.0";
  format = "pyproject";

  src = ./.; # points to the root of the os-update package dir

  nativeBuildInputs = with pkgs.python311Packages; [ hatchling ];

  # No runtime Python deps — stdlib only (tomllib is 3.11+)
  propagatedBuildInputs = [ ];

  # nixos-rebuild must be available at runtime on the host,
  # we don't bundle it here — it's always present on NixOS
  makeWrapperArgs =
    [ "--prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.nixos-rebuild ]}" ];

  meta = with pkgs.lib; {
    description = "Update a NixOS system from a local TOML config file";
    license = licenses.mit;
    mainProgram = "os-update";
  };
}
