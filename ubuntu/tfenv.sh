#!/bin/bash

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "git is required but it's not installed. Install git and run the script again."
    exit 1
fi

# Define installation directory
TFENV_ROOT="${HOME}/.tfenv"

# Function to append to a new line in a file
append_to_new_line() {
    local file=$1
    local line=$2

    # Check if the file ends with a newline
    if [ -s "$file" ] && [ -n "$(tail -c 1 "$file")" ]; then
        echo "" >> "$file"
    fi

    echo "$line" >> "$file"
}

# Check if tfenv is already installed
if [ -d "$TFENV_ROOT" ]; then
    if ! grep -q 'export PATH="$HOME/.tfenv/bin:$PATH"' ~/.profile; then
        append_to_new_line ~/.profile 'export PATH="$HOME/.tfenv/bin:$PATH"'
    fi
    echo "tfenv is already installed"
else
    # Clone tfenv repository from GitHub
    git clone https://github.com/tfutils/tfenv.git ~/.tfenv

    # Add tfenv to path
    append_to_new_line ~/.profile 'export PATH="$HOME/.tfenv/bin:$PATH"'

    # Reload profile
    source ~/.profile

    # Verify the installation
    tfenv --version
fi
