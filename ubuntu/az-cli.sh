#!/bin/bash

# Check if curl is installed
if ! command -v curl &> /dev/null; then
  echo "curl is required but it's not installed. Install curl and run the script again."
  exit 1
fi

# Determine the system architecture
ARCHITECTURE=$(dpkg --print-architecture)

# Set the appropriate repository URL based on the architecture
if [ "$ARCHITECTURE" == "amd64" ]; then
  REPO_URL="https://packages.microsoft.com/repos/azure-cli/"
  ARCH="amd64"
elif [ "$ARCHITECTURE" == "armhf" ] || [ "$ARCHITECTURE" == "arm64" ]; then
  REPO_URL="https://packages.microsoft.com/repos/azure-cli/"
  ARCH="arm64"
else
  echo "Unsupported architecture: $ARCHITECTURE"
  exit 1
fi

# Download and install the Microsoft signing key
curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
  gpg --dearmor | \
  sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

# Add the Azure CLI software repository
echo "deb [arch=$ARCH] $REPO_URL $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/azure-cli.list

# Update repository information and install the azure-cli package
sudo apt-get update
sudo apt-get install azure-cli -y

# Verify the installation
az --version
