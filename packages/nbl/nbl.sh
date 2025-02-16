#!/bin/bash
set -o

# Check if an argument is provided
if [ $# -eq 0 ]; then
  printf "\033[0;35mUsage\033[0m: nbl <build-argument>\n"
  exit 1
fi
printf "building \033[0;36m%s\033[0m with options : \033[0;33m%s\033[0m" "$1" "${@: -2}" 

# run build command in a background process
eval 3<(nix build "$@" 2>&1)
PID=$!
i=1
sp="/-\|"
echo -n ' '
while [ -d /proc/$PID ]
do
  read -r <&3 line;
  printf "\b%s %s" "$line" "${sp:i++%${#sp}:1}"
  build_output+="$line"$'\n'
  sleep 0.1
done
# wait for execution
wait $PID
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