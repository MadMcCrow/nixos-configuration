# modules :

All configuration modules are independant and only imported if necessary.
this is done so that non-imported modules don't get parsed if not in use (no web server parsing if no web server on the machine for example).

## linux
this is our core linux config. maybe it could benefit from splitting in separate files for filesystems and other things

## desktop
KDE desktop (for now). this is made for having a nice linux desktop

## games
tools to better run games on nixos. requires (linux)[##linux].

## shared
modules useful both in linux and macOS

## vm
module to turn a system into a VM

## web
a cool web/cloud server. linux only (relies on systemd). has no external dependencies.

## macos
nix-darwin module for MacOS.