#!/bin/zsh

echo "\nInstalling Spin CLI..."
curl -LO https://storage.googleapis.com/spinnaker-artifacts/spin/$(curl -s https://storage.googleapis.com/spinnaker-artifacts/spin/latest)/darwin/amd64/spin
chmod +x spin
sudo mv spin /usr/local/bin/spin
