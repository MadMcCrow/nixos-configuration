#!/bin/sh
# install script that checks that nix is properly installed,
# that experimental nix features are enabled, and then 
# installs the latest configuration for your MacOS device
#
# it also works as an updater, and almost without cloning 
# the repo in the first place (you need to have installed
# nix darwin at least once before )
#
# TODO: install without cloning this repo :)

# flake this script belongs to :
FLAKE="github:MadMcCrow/nixos-configuration"

clean_backup()
{
if [ -f "/etc/$1.backup-before-nix" ]; then
  echo "reverting backup of $1"
  sudo mv "/etc/$1.backup-before-nix" "/etc/$1"
fi
}

install_nix()
{
  if ! [ -x "$(command -v nix)" ]; then
    # this script remove what blocks the reinstall of nix after an update
    clean_backup  bashrc
    clean_backup  zshrc
    clean_backup  bash.bashrc
    # launch installer
    curl -L https://nixos.org/nix/install | sh
  else
    echo "nix already installed, skipping"
  fi
}

experimental_features()
{
  EXPERIMENTALFEATURES="experimental-features = nix-command flakes"
  NIXCONFPATH="$HOME/.config/nix"
  mkdir -p "$NIXCONFPATH"
  touch "$NIXCONFPATH/nix.conf"
  if ! grep -q "$EXPERIMENTALFEATURES" "$NIXCONFPATH/nix.conf";
  then
  echo "adding experimental features"
  echo "$EXPERIMENTALFEATURES" >> "$NIXCONFPATH/nix.conf"
  else
  echo "experimental features already enabled, skipping"
  fi
}

switch()
{
  # find host name
  if [ -z "$1" ]
  then
    HOST=$1
  else
    HOST=$(hostname -s)
  fi
  # local build or call as script :
  if [ -e $(git rev-parse --show-toplevel)/flake.nix ]
  then
  echo "building configuration for $HOST"
  nix build ".#darwinConfigurations.$HOST.system"
  echo "applying build configuration $HOST"
  ./result/sw/bin/darwin-rebuild switch --flake .#$HOST
  else
    # you must have already installed once to be there anyway !
    echo "building configuration for $HOST"
    darwin-rebuild switch --flake $FLAKE#$HOST
  fi
}

# install nix if nix is not present
install_nix
# enable experimental features
experimental_features
# build MacOS configuration
switch

CURRENT_GEN=$(nix-env --list-generations | grep current | awk '{print $1}')
echo "Successfully installed $(hostname -s)#$CURRENT_GEN"
