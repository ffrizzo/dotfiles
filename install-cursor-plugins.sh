#!/bin/zsh
echo "\nInstalling Brewfile's vscode extensions into Cursor..."

grep -oE '^vscode "[^"]+"' Brewfile | sed -E 's/vscode "//;s/"//' | while read -r extension; do
  cursor --install-extension "$extension"
done
