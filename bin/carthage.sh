#!/usr/bin/env bash

# Ref for below Xcode 13 workaround: https://github.com/Carthage/Carthage/issues/3019
# Remove workaround once Carthage team have fixed this.

set -euo pipefail

xcconfig=$(mktemp /tmp/static.xcconfig.XXXXXX)
trap 'rm -f "$xcconfig"' INT TERM HUP EXIT


# For Xcode 13 make sure EXCLUDED_ARCHS is set to arm architectures otherwise
# the build will fail on lipo due to duplicate architectures.

CURRENT_XCODE_VERSION=$(xcodebuild -version | grep "Build version" | cut -d' ' -f3)
echo "EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1300__BUILD_$CURRENT_XCODE_VERSION = arm64 arm64e armv7 armv7s armv6 armv8" >> $xcconfig

echo 'EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1300 = $(EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_1300__BUILD_$(XCODE_PRODUCT_BUILD_VERSION))' >> $xcconfig
echo 'EXCLUDED_ARCHS = $(inherited) $(EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_$(EFFECTIVE_PLATFORM_SUFFIX)__NATIVE_ARCH_64_BIT_$(NATIVE_ARCH_64_BIT)__XCODE_$(XCODE_VERSION_MAJOR))' >> $xcconfig

export XCODE_XCCONFIG_FILE="$xcconfig"

# If not running on CircleCI, pass args through
if [ -z "${CIRCLECI:-}" ]; then
  carthage "$@"
# Else if running on CircleCI and no cache found, ensure latest carthage and build resolved dependencies
elif ! cmp -s Cartfile.resolved Carthage/Cartfile.resolved; then
  # When the cache was last reset, we ran into a mirror issue that was fixed by adding
  # the following preix as an environment variable:
  #HOMEBREW_BOTTLE_DOMAIN=https://ghcr.io/v2/Homebrew/core
  # Related: https://discuss.circleci.com/t/homebrew-stopped-to-download-openssl-1-1/39828
  HOMEBREW_BOTTLE_DOMAIN=https://ghcr.io/v2/Homebrew/core brew upgrade carthage
  echo "Resolving dependencies"
  carthage bootstrap --platform iOS
  cp Cartfile.resolved Carthage
fi
