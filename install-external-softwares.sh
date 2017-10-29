#!/bin/bash
echo ""
echo "Installing wercker"
curl https://s3.amazonaws.com/downloads.wercker.com/cli/stable/darwin_amd64/wercker -o /usr/local/bin/wercker
chmod +x /usr/local/bin/wercker

echo ""
echo "Installing travis command line"
sudo gem update --system
sudo gem install travis --no-rdoc --no-ri
