#!/bin/sh


clean_backup()
{
if [ -f "/etc/$1.backup-before-nix" ]; then
  echo "reverting backup of $1"
  sudo mv "/etc/$1.backup-before-nix" "/etc/$1"
fi
}

uninstall()
{
  # reset all rcs to before nix
  clean_backup  bashrc
  clean_backup  zshrc
  clean_backup  bash.bashrc
  # stop and clean nix daemon
  sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist
  sudo rm /Library/LaunchDaemons/org.nixos.nix-daemon.plist
  sudo launchctl unload /Library/LaunchDaemons/org.nixos.darwin-store.plist
  sudo rm /Library/LaunchDaemons/org.nixos.darwin-store.plist
  # Remove the nixbld group and the _nixbuildN users:
  sudo dscl . -delete /Groups/nixbld
  for u in $(sudo dscl . -list /Users | grep _nixbld); do sudo dscl . -delete /Users/$u; done
  # to check  :
  # remove nix from /etc/synthetic.conf
  sudo sed -i "/nix/d" /etc/synthetic.conf
  # remove files related to nix
  sudo rm -rf /etc/nix /var/root/.nix-profile /var/root/.nix-defexpr /var/root/.nix-channels ~/.nix-profile ~/.nix-defexpr ~/.nix-channels
  #Remove the Nix Store volume:
  sudo /usr/sbin/diskutil apfs deleteVolume /nix
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

build()
{
  # build nix config on Darwin
  echo "building configuration for $(hostname -s)"
  nix build ".#darwinConfigurations.$(hostname -s).system"
}

apply()
{
if [ -f "./result/sw/bin/darwin-rebuild" ]; then
  ./result/sw/bin/darwin-rebuild switch --flake .#
else
  echo "fail to apply config, no succesful build"
fi
}

# add the option to uninstall
if [ "$1" = "-U" ];
then
uninstall
exit
fi

# add the option to uninstall
if [ "$1" = "-B" ];
then
build
exit
fi

# install nix if nix is not present or forced install
if [ "$1" = "-f" ];
then
uninstall
install_nix
elif ! [ -x "$(command -v nix)" ];
then
install_nix
else
echo "nix already installed, skipping"
fi


# enable experimental features
experimental_features
# build MacOS configuration
build
# apply config
apply

echo "Nix install done"
