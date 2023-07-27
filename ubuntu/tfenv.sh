#!/bin/bash

# Check if git is installed
if ! command -v git &> /dev/null
then
    echo "git is required but it's not installed. Install git and run the script again."
    exit
fi

# Define installation directory
TFENV_ROOT="${HOME}/.tfenv"

# Check if tfenv is already installed
if [ -d "$TFENV_ROOT" ]; then
    if ! grep -q 'export PATH="$HOME/.tfenv/bin:$PATH"' ~/.profile; then
        echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.profile
    fi
    echo "tfenv is already installed"
else
    # Clone tfenv repository from GitHub
    git clone https://github.com/tfutils/tfenv.git ~/.tfenv

    # Add tfenv to path
    echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.profile

    # Reload profile
    source ~/.profile

    # Verify the installation
    tfenv --version
fi

