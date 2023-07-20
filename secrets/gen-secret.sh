#!/usr/bin/env sh

# Colors for output
GRE='\033[0;32m'
BLU='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# sysarg variable
KEY="$1"
STORE="$2"
SECRET="$3"

# count characters
ccount() {
    nc=$(echo $1  | sed 's/\\033\[[0-9;]\{1,\}m//g' )
    nn=$(echo $nc | sed 's/\\0//g')
    echo ${#nn}
}

# echo on a dotted line
echo_line() {
  local t=" $1 "
  local l=50
  local c=$(ccount "$1")
  local p=true
  while [ $c -lt $l ]; do
    if $p; then
      t="${t}-"
      p=false
    else
      t="-${t}"
      p=true
    fi
    c=$(( c + 1 ))
  done
  echo -e "$t"
}

# handle input
handle_empty_input() {
  local var_name="$1"
  local default_value="$2"
  local prompt_text="$3"
  if [ -z "${!var_name}" ]; then
     echo -e  "$RED\0No $prompt_text found$NC"
    read -p "$prompt_text: [${!var_name:-$default_value}] :" input
    if [ -z "$input" ]; then
      echo -e "defaulting to ${!var_name:-$default_value}"
      eval "$var_name=\$default_value"
    else
      eval "$var_name=\$input"
    fi
  fi
}

# inputs
if [ -z $KEY ] || [ -z $STORE -o -z $SECRET ]
then
echo_line "input key name and storage for $GRE\0Agenix$NC"
handle_empty_input "KEY" "nixos" "Key name"
handle_empty_input "STORE" "/persist/secrets" "store path"
handle_empty_input "SECRET" "$KEY.age" "secret name"
fi
# gen key
echo_line "Generating key for $GRE\0$KEY\0$NC"
if [ -e "$KEY" -a -e "$KEY.pub" ]; then
     echo -e  "key already created, $RED\0skipping$NC"
else
    ssh-keygen -C $KEY -f ./$KEY  -q
    echo -e "private key generated at $BLUE\0$PWD/$KEY\0$NC"
fi
# store key
echo_line "Storing private key in $GRE\0$STORE\0$NC"
if [ -e "$/STORE/$KEY" ]; then
    red "private key already present in store, overriding"
fi
sudo cp ./$KEY $STORE/$KEY
# edit or create secret
echo_line "editing secret in $GRE\0$SECRET\0$NC"
agenix -e $SECRET -i $STORE/$KEY
# tell user what to do next
echo -e "you can now edit secret file $SECRET with agenix with $BLU'agenix -e $SECRET -i $STORE/$KEY'$NC"
echo_line "$GRE\0DONE$NC"
