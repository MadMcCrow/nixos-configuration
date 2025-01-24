#!/bin/sh
set -o

# Check if an argument is provided
if [ $# -eq 0 ]; then
  printf "\033[0;35mUsage\033[0m: nbl <build-argument>\n"
  exit 1
fi
printf "building \033[0;36m$1\033[0m with options : \033[0;33m${@: -2}\033[0m"

# run build command in a background process
exec 3<(nix build "$@" 2>&1)
PID=$!
i=1
sp="/-\|"
echo -n ' '
while [ -d /proc/$PID ]
do
  read <&3 line;
  printf "\b$line ${sp:i++%${#sp}:1}"
  sleep 0.1
done
build_exit_code=wait $PID
build_exit_code=$?

# Check if the build failed
if [ $build_exit_code -ne 0 ]; then
  store_path=$(echo "$build_output" | sed -n "s/.*nix log \([^']*.drv\).*/\1/p")

  if [ -n "$store_path" ]; then
    echo "Build failed. Showing logs for: $store_path"
    nix log "$store_path"
  else
    echo "Build failed and no store path found in the error message."
    echo "$build_output"
  fi
else
  echo "Build succeeded."
  echo "$build_output"
fi