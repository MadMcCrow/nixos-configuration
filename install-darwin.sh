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
  # this script remove what blocks the reinstall of nix after an update
  clean_backup  bashrc
  clean_backup  zshrc
  clean_backup  bash.bashrc
  # launch installer
  curl -L https://nixos.org/nix/install | sh
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
 

# install nix if nix is not present
if ! [ -x "$(command -v nix)" ]; then
  install_nix
fi

# enable experimental features
experimental_features

# build nix config on Darwin
# TODO : make this dynamic
nix build '.#darwinSystems.Noes-MacBook-Air.system'

# apply config
./result/sw/bin/darwin-rebuild switch --flake 


