#!/usr/bin/env bash
# fs-diff.sh
set -euo pipefail

OLD_TRANSID=$(sudo btrfs subvolume list "/root" | grep "root-old" | sort -k 2 -n | tail -n 1 | awk '{print $4 }')

sudo btrfs subvolume find-new "/" "$OLD_TRANSID" |
sed '$d' |
cut -f17- -d' ' |
sort |
uniq |
while read path; do
  path="/$path"
  if [ -L "$path" ]; then
    : # The path is a symbolic link, so is probably handled by NixOS already
  elif [ -d "$path" ]; then
    : # The path is a directory, ignore
  else
    echo "$path"
  fi
done
