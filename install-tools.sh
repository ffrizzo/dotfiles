#!/bin/zsh

echo "\nInstalling Spin CLI..."
curl -o /usr/local/bin/spin https://storage.googleapis.com/spinnaker-artifacts/spin/$(curl -s https://storage.googleapis.com/spinnaker-artifacts/spin/latest)/darwin/amd64/spin
chmod +x /usr/local/bin/spin
