#!/bin/bash

# Get the latest repo tag
get_latest_tag() {
  git tag --sort=-v:refname | head -n 1 | tr -d "v"
}

# Increment the version
increment_version() {
  local version=$1
  local commit_type=$2
  local major minor patch
  IFS='.' read -r major minor patch <<< "$version"
  
  if [[ "${commit_type,,}" == "major" ]]; then
      major=$((major + 1))
      minor=0
      patch=0
  elif [[ "${commit_type,,}" == "minor" ]]; then
      minor=$((minor + 1))
      patch=0
  elif [[ "${commit_type,,}" == "patch" ]]; then
      patch=$((patch + 1))
  else
      echo "Invalid commit type";
  fi
  
  echo "v$major.$minor.$patch"
}

create_github_release() {
  local tag=$1
  gh release create "$tag" --title "Release $tag" --notes "Automated release for version $tag"
}

main() {
  commit_type="${1:-patch}"
  latest_tag=$(get_latest_tag)
  
  if [[ -z "$latest_tag" ]]; then
    tag="v1.0.0"   
    git tag "$tag"
    git push origin "$tag"
    create_github_release "$tag"
    echo "No tags found in the repository. Created v1.0.0."
  else
      new_tag=$(increment_version "$latest_tag" "$commit_type")
      git tag "$new_tag"
      git push origin "$new_tag" &> /dev/null
      echo "Created and pushed new tag: $new_tag"

      create_github_release "$new_tag" &> /dev/null
      echo "Created GitHub release for tag: $new_tag"
  fi
}

main "$@"
