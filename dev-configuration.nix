# configuration for software development
{ config, lib, pkgs, modulesPath, ... }: {
  environment.systemPackages = with pkgs; [
    git
    gh
    gcc
    clang
    lld
    gnumake
    cmake
    rust-bindgen
    rust-analyzer
    rustup
    rustc
    rustfmt
    rust-code-analysis
    rustracer
    rust-script
    patchelf
  ];
}

