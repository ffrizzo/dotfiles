#!/bin/bash
echo ""
echo "Installing wercker"
curl https://s3.amazonaws.com/downloads.wercker.com/cli/stable/darwin_amd64/wercker -o /usr/local/bin/wercker
chmod +x /usr/local/bin/wercker

echo "Installing docker-osx-dev"
curl -o /usr/local/bin/docker-osx-dev https://raw.githubusercontent.com/brikis98/docker-osx-dev/master/src/docker-osx-dev
chmod +x /usr/local/bin/docker-osx-dev
docker-osx-dev install

echo ""
echo "Installing travis command line"
sudo gem update --system
sudo gem install travis --no-rdoc --no-ri
