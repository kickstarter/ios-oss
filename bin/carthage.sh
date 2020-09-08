#!/bin/sh

# Cache Cartfile
if [ -n "$FORCE_CARTHAGE" ] || ! cmp -s Cartfile.resolved Carthage/Cartfile.resolved; then
  # If not running on CircleCI, update dependencies
  if [ -z "${CIRCLECI:-}" ]; then
    echo "Updating dependencies"
    carthage update --platform iOS
  # Else if running on CircleCI, build resolved dependencies
  else
    echo "Resolving dependencies"
    carthage bootstrap --platform iOS
  fi
  cp Cartfile.resolved Carthage
fi
