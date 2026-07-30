#!/bin/zsh
# Mirror of setup.sh's `cp -a ./home/ ~/`, but in reverse: pulls each tracked
# dotfile back from $HOME into ./home/ so local edits can be reviewed and
# committed instead of silently drifting out of sync with the repo.
echo "\nSyncing tracked dotfiles back from ~ into ./home ..."

find ./home -type f | while read -r file; do
  relative_path=${file#./home/}
  source="$HOME/$relative_path"
  if [ -f "$source" ]; then
    cp -a "$source" "$file"
    echo "Synced $relative_path"
  else
    echo "Skipped $relative_path (not found in \$HOME)"
  fi
done
