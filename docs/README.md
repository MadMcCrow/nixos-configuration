# Non-OS

Non-OS in my opiniated version of [NixOS](https://nixos.org/). we do not deploy like a normal NixOS installation.

This repo contains the necessary Nix modules to build my systems. The modules provides what I consider necessary for my machines. this means that it may not fit your particular configuration. however there's options to control aspects of the modules. 

## concepts

### erase your darlings...
root is tmpfs. this means that everything is in the store or gets erased.

### npins locally, flake globally
the flake defines the os, the machine defines itself. all the config values and the nixpkgs version lives on your machine.
for that, we use npins. we provide a script to manage npins updates for you.

### single drive machines
Machine are linux PCs. they usually have one main drive, always in the form of some NAND memory (SSDs and such). extra drives are usually machine specific enough to not belong here.