#!/usr/bin/env bash

set -euo pipefail

# If not running on CircleCI, pass args through
if [ -z "${CIRCLECI:-}" ]; then
  xcodebuild "$@"
# Else if running on CircleCI and no cache found, ensure latest carthage and build resolved dependencies
elif ! cmp -s ./Kickstarter.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved SourcePackages/Package.resolved; then
  echo "Resolving SPM Dependencies"
  xcodebuild -resolvePackageDependencies -clonedSourcePackagesDirPath SourcePackages
  cp Package.resolved SourcePackages
fi
