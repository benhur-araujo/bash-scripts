#!/bin/bash

usage() {
    echo "$0 PROGRAM_NAME SEMVER"
    echo "E.g: $0 focus-chunker minor"
    exit 1
}

# Get the latest repo tag
get_latest_tag() {
  git tag --sort=-v:refname | grep "$1" | head -n 1 | sed "s/$1-v//"
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
  fi
  
  echo "v$major.$minor.$patch"
}

create_github_release() {
  local tag=$1
  gh release create "$tag" --title "$tag" --notes "Automated release for version $tag"
}

main() {
  scope="$1"
  commit_type="${2:-patch}"
  if [[ "$commit_type" != "major" && "$commit_type" != "minor" && "$commit_type" != "patch" ]]; then
      usage
  fi

  latest_tag=$(get_latest_tag "$scope")
  
  if [[ -z "$latest_tag" ]]; then
    tag="$scope-v1.0.0"   
    git tag "$tag"
    git push origin "$tag"
    create_github_release "$tag"
    echo "No tags found in the repository. Created tag $tag"
  else
      new_tag=$(increment_version "$latest_tag" "$commit_type")
      git tag "$scope-$new_tag"
      git push origin "$scope-$new_tag" &> /dev/null
      echo "Created and pushed new tag: $scope-$new_tag"

      create_github_release "$scope-$new_tag" &> /dev/null
      echo "Created GitHub release for tag: $scope-$new_tag"
  fi
}

main "$@"
