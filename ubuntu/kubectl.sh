#!/bin/bash

# Find the latest version.
VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
echo "Downloading kubectl version $VERSION ..."

# Download kubectl.
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$VERSION/bin/linux/amd64/kubectl"

# Make the downloaded file executable.
chmod +x ./kubectl

# Move the executable to your path.
sudo mv ./kubectl /usr/local/bin/kubectl

# Verify the installation.
kubectl version --client
