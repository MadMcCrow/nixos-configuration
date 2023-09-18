# default.nix
#	development
# support for programming languages
{ pkgs, config, lib, nixpkgs, system, ... }:
with builtins;
with lib;
let
  cfg = config.development;
 langs = {
  c = {
    packages = with pkgs; [gcc clang]; 
  };
  rust = {
    packages = with pkgs;[cargo rustc];
  };
  python = {
    packages = with pkgs; [python3Full];
  }
  };

in {

  # interface : a way to expose settings
  options.development = {
    enable = mkEnableOption "enable programming tools support" // {default = true;};
    languages = mkOption {
      type = types.listOf types.str;
       default = ["c" "rust"];
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = concatLists (map (x : langs.${x}.packages) cfg.languages);
  };
}
