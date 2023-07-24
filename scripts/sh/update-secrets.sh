#!/bin/bash

# Check if the correct number of arguments is provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <ssh_key_location> <secret_file_location1> [<secret_file_location2> ...]"
    exit 1
fi

# Read the SSH key location from the first argument
SSH_KEY_LOCATION="$1"

# Remove the first argument (SSH key location) from the list of arguments
shift

# Check if the SSH key exists at the specified location
if [ ! -f "$SSH_KEY_LOCATION" ]; then
    echo "SSH key not found at $SSH_KEY_LOCATION. Creating a new one..."
    ssh-keygen -C "$SSH_KEY_LOCATION" -f "./$SSH_KEY_LOCATION" -q
fi

# Loop through each secret file location provided as arguments
for SECRET_FILE_LOCATION in "$@"; do
    if [ -f "$SECRET_FILE_LOCATION" ]; then
        echo "Secret file found at $SECRET_FILE_LOCATION. Trying to open it..."
        if age -d -i "$SSH_KEY_LOCATION" -o "$SECRET_FILE_LOCATION"; then
            echo "Success! Here is the content of the secret file:"
            cat "$SECRET_FILE_LOCATION"
        else
            echo "Failed to open the secret file. Deleting and recreating it..."
            rm "$SECRET_FILE_LOCATION"
            age -i "$SSH_KEY_LOCATION" -o "$SECRET_FILE_LOCATION"
        fi
    else
        echo "Secret file not found at $SECRET_FILE_LOCATION. Creating a new one..."
        age -i "$SSH_KEY_LOCATION" -o "$SECRET_FILE_LOCATION"
    fi
done
