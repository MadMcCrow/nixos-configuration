#!/usr/bin/env bash
# install script that checks that nix is properly installed,
# that experimental nix features are enabled, and then 
# installs the latest configuration for your MacOS device
#
# it also works as an updater, and almost without cloning 
# the repo in the first place (you need to have installed
# nix darwin at least once before )

# TODO : replace by the correct command name
script_dir=$(dirname "$0")
script=$(basename "$script_dir")
log=/tmp/$script
drybuild=1
logview=10

function background() {
  exec 3<> "$log" #open fd 3.
  eval "$1 " 1>&3 2>&3 &
  pid=$!
  i=1
  sp="/-\|"
  trap 'kill "$pid" 2> /dev/null' EXIT
  while kill -0 $pid 2> /dev/null;
  do
    read -r <&3 line;
    line="$(printf "%s" "$line" | tr -d '\n')"
    printf "\r\033[2K%s \033[;2m%s\033[;0m" "${sp:i++%${#sp}:1}" "$line"
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
  for backup in "${array[@]}"; do
    if [ -f "/etc/$backup.backup-before-nix" ]; then
      printf "\033[;2mreverting backup of %s\n" "$backup"
      sudo mv "/etc/$backup.backup-before-nix" "/etc/$backup"
    fi
  done
  # launch installer
  curl -L https://nixos.org/nix/install | sh
  retcurl=$?
  if [ $retcurl -ne 0 ]; then 
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

# DRY BUILD
if [ $drybuild -eq 0 ]; then
  printf "dry-building configuration for \033[;35m%s\033[0m\n" "$host"
  background "nix build $target --dry-run --no-eval-cache --quiet"
  retbuild=$?
  if [ $retbuild -ne 0 ]; then
    printf "\033[;31mError:\033[;m failed to dry build \033[;35m%s\033[0m\n" "$host" 1>&2
  else
    printf "Successfully built \033[;35m%s\033[0m\n" "$host"
  fi
  < "$log" tail -n $logview
  rm "$log"
  exit $retbuild
fi

# ROOT IS NECESSARY PAST THIS POINT
if [ "$USER" != "root" ]; then
    >&2 printf "\033[0;33merror:\033[0m please run nixos-update as root or with sudo\n"
    exit 2
fi

# REBUILD with darwin-rebuild :
if [[ -x "$(command -v darwin-rebuild)" ]]; then
  echo "rebuilding configuration for $host"
  darwin-rebuild switch --flake "$flake#$host"
  retrebuild=$?
  if [ $retrebuild -eq 0 ]; then
    currentgen=$(nix-env --list-generations | grep current | awk '{print $1}')
    printf "Successfully switched \033[;35m%s#%s\033[0m\n" "$host" "$currentgen"
  else 
    printf "\033[;31mError:\033[;m failed to rebuild \033[;35m%s\033[0m\n" "$host" 1>&2
  fi
# build from scratch
else
  printf "building configuration for \033[;35m%s\033[0m\n" "$host"
  background "nix build $target"
  retbuild=$?
  if [[ retbuild -eq 0 ]]; then
      rm "$log"
      printf "applying build configuration \033[;35m%s\033[0m\n" "$host"
      ./result/sw/bin/darwin-rebuild switch --flake ".#$host"
      retapply=$?
      rm ./result || true # remove symlink for cleaner install
      if [ $retapply -eq 0 ]; then 
        printf "Successfully installed 033[;35m%s\033[0m\n" "$host"
        exit 0
      else
        printf "\033[;31mError:\033[;m failed to apply \033[;35m%s\033[0m\n" "$host" 1>&2
        exit 1
      fi
  else
    printf "\033[;31mError:\033[;m failed to build \033[;35m%s\033[0m\n" "$host" 1>&2
    < "$log" tail -n $logview
    rm "$log"
    exit 1
  fi
fi