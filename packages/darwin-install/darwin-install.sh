#!/usr/bin/env bash
# install script that checks that nix is properly installed,
# that experimental nix features are enabled, and then 
# installs the latest configuration for your MacOS device
#
# it also works as an updater, and almost without cloning 
# the repo in the first place (you need to have installed
# nix darwin at least once before )

# TODO : replace by the correct command name
script=$(basename $(dirname $0))
log=/tmp/$script
drybuild=1

function background() {
  exec 3<> $log #open fd 3.
  eval "$1 " 1>&3 2>&3 &
  pid=$!
  i=1
  sp="/-\|"
  trap "kill $pid 2> /dev/null" EXIT
  while kill -0 $pid 2> /dev/null;
  do
    read <&3 line;
    line="$(printf "$line" | tr -d '\n')"
    printf "\r\033[2K${sp:i++%${#sp}:1} \033[;2m$line\033[;0m"
    sleep 0.01
  done
  printf "\r\033[2K"
  wait $pid
  code=$?
  trap - EXIT
  exec 3>&- #close fd 3.
  return $code
}

# Parse Inputs
while [ "$#" -gt 0 ]; do
  if [[ $1 =~ (-h)|(--help) ]]; then
    printf "\033[;35mdarwin-install HOST [-b]\033[0m\n"
    printf "\HOST\t\t\tmacOS machine to install\n"
    printf "\t-d, --dry-run     \tonly perform a dry run of build\n"
    exit 0
  fi
  if [[ $1 =~ (-d)|(--dry-run) ]]; then
    drybuild=0; shift;
    continue
  fi
  host=$1
  shift
done

# fix not provided host
if ! [ -e "$host" ]; then
    host=$(hostname -s)
fi

if [ -e "$(git rev-parse --show-toplevel)/flake.nix" ]; then
flake="."
else
flake="github:MadMcCrow/nixos-configuration"
fi



# install nix if nix is not present
if ! [ -x "$(command -v nix)" ]; then
  declare -a array=("bashrc" "zshrc" "bash.bashrc")
  for backup in array; do
  if [ -f "/etc/$1.backup-before-nix" ]; then
    printf "\033[;2mreverting backup of $1\n"
    sudo mv "/etc/$1.backup-before-nix" "/etc/$1"
  fi
  done
  # launch installer
  curl -L https://nixos.org/nix/install | sh
  if [ $? != 0 ]; then 
    printf "\033[;31mError:\033[;m failed to install nix\n" 1>&2
    exit 3
  fi
fi

# make sure that experimental features are enabled
expfeatures="experimental-features = nix-command flakes"
nixconfpath="$HOME/.config/nix"
mkdir -p "$nixconfpath"
touch "$nixconfpath/nix.conf"
if ! grep -q "$expfeatures" "$nixconfpath/nix.conf"; then
  echo "adding experimental features"
  echo "$expfeatures" >> "$nixconfpath/nix.conf"
fi

# build MacOS configuration
#TODO: wrap build command in threaded function 
target="\"$flake#darwinConfigurations.$host.system\""
if [ $drybuild -eq 0 ]; then
  printf "dry-building configuration for \033[;35m$host\033[0m\n"
  background "nix build $target --dry-run --no-eval-cache --quiet"
  if [ $? == 0 ]; then
    printf "Successfully built \033[;35m$host\033[0m\n"
    rm $log
    exit 0
  else
    printf "\033[;31mError:\033[;m failed to dry build \033[;35m$host\033[0m\n" 1>&2
    cat $log | tail -n 8
    rm $log
    exit 1
  fi
elif [[ -x "$(command -v darwin-rebuild)" ]]; then
  echo "rebuilding configuration for $host"
  darwin-rebuild switch --flake "$flake#$host"
  if [ $? == 0 ]; then
    currentgen=$(nix-env --list-generations | grep current | awk '{print $1}')
    printf "Successfully switched \033[;35m$host#$currentgen\033[0m\n"
  else 
    printf "\033[;31mError:\033[;m failed to rebuild \033[;35m$host\033[0m\n" 1>&2
  fi
else
  printf "building configuration for \033[;35m$host\033[0m\n"
  background "nix build $target"
  if [ $? == 0 ]; then
      rm $log
      printf "applying build configuration \033[;35m$host\033[0m\n"
      ./result/sw/bin/darwin-rebuild switch --flake ".#$HOST"
      rm ./result || true # remove symlink for cleaner install
      if [ $? == 0 ]; then 
        printf "Successfully installed 033[;35m$host\033[0m\n"
        exit 0
      else
        printf "\033[;31mError:\033[;m failed to apply \033[;35m$host\033[0m\n" 1>&2
        exit 2
      fi
  else
    printf "\033[;31mError:\033[;m failed to build \033[;35m$host\033[0m\n" 1>&2
    cat $log | tail -n 8
    rm $log
    exit 1
  fi
fi