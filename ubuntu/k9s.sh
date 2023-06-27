#!/bin/bash

# Get latest release
VERSION=$(curl --silent "https://api.github.com/repos/derailed/k9s/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

# Download and unzip
curl -LO "https://github.com/derailed/k9s/releases/download/${VERSION}/k9s_Linux_amd64.tar.gz"
tar -xvzf k9s_Linux_amd64.tar.gz

# Move to /usr/local/bin for global access
sudo mv k9s /usr/local/bin/

# Remove downloaded files
rm k9s_Linux_amd64.tar.gz

# Verify Installation
k9s version