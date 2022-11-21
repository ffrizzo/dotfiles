#!/bin/zsh

echo "\nInstalling Spin CLI..."
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
VERSION=$(curl -s https://storage.googleapis.com/spinnaker-artifacts/spin/latest)
curl -o /usr/local/bin/spin https://storage.googleapis.com/spinnaker-artifacts/spin/$VERSION/$OS/$ARCH/spin
chmod +x /usr/local/bin/spin
