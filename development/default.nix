# default.nix
#	development
# support for programming languages
{ pkgs, config, lib, nixpkgs, system, ... }:
with builtins;
let
  cfg = config.development;
  langs = {
    c = { packages = with pkgs; [ clang ]; };
    rust = { packages = with pkgs; [ cargo rustc ]; };
    python = { packages = with pkgs; [ python3Full ]; };
    haxe = { packages = with pkgs; [ haxe haxePackages.hxcpp ]; };

  };

in {

  # interface : a way to expose settings
  options.development = {
    enable = lib.mkEnableOption "enable programming tools support" // {
      default = true;
    };
    languages = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ "c" "rust" "haxe" ];
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      concatLists (map (x: langs.${x}.packages) cfg.languages);
  };
}
