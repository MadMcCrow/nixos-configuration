#!/bin/sh

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
  ExperimentalFeatures="experimental-features = nix-command flakes"
  NixConfPath="${HOME}/.config/nix"
  mkdir -p "${NixConfPath}"
  touch "${NixConfPath}/nix.conf"
  if ! grep -q "$ExperimentalFeatures"  "${NixConfPath}/nix.conf"; then
  echo "adding experimental features"
  echo "$ExperimentalFeatures" >> "${NixConfPath}/nix.conf"
  else
  echo "experimental features already enabled"
  fi
}

build()
{
  # build nix config on Darwin
  host=${HOSTNAME/.local}
  echo "building configuration for $host"
  nix build ".#darwinSystems.$host.system"
}

apply()
{
  ./result/sw/bin/darwin-rebuild switch --flake .#
}

# install nix if nix is not present
install_nix
# enable experimental features
experimental_features
# build MacOS configuration
build
# apply config
apply

echo "Nix install done"
