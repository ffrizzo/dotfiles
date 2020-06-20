#!/bin/zsh

printf "\nInstalling Spin CLI...\n"
curl -LO https://storage.googleapis.com/spinnaker-artifacts/spin/$(curl -s https://storage.googleapis.com/spinnaker-artifacts/spin/latest)/darwin/amd64/spin
chmod +x spin
sudo mv spin /usr/local/bin/spin

printf "\nInstalling Arkade...\n"
curl -sLS https://dl.get-arkade.dev | sudo sh

printf "\nInstalling k3sup...\n"
curl -sLS https://get.k3sup.dev | sh

K3D_VERSION="${K3D_VERSION:-latest}"
printf "\nInstalling K3D ${K3D_VERSION}...\n"
if [[ "$K3D_VERSION" == "latest" ]]; then
    curl -s https://raw.githubusercontent.com/rancher/k3d/master/install.sh | sh
else
    curl -s https://raw.githubusercontent.com/rancher/k3d/master/install.sh | TAG=$K3D_VERSION sh
fi