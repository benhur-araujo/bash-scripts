#!/bin/bash

tags="$(git tag --list)"

tags_array=()
while read -r line; do
    tags_array+=("$line")
done <<< "$tags"

for tag in "${tags_array[@]}"; do
    git push origin --delete "$tag"
    git tag --delete "$tag"
done
