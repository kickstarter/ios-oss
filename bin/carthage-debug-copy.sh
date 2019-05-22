#!/bin/sh

if [ "$CONFIGURATION" == "Debug" ]; then
  /usr/local/bin/carthage copy-frameworks
fi
