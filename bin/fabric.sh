#!/bin/sh

if [ ! -z "$CI" ] && [ ! -z "$FABRIC_API_KEY" ]; then
  echo "Configuring Fabric..."
  ../Frameworks/Fabric/Fabric.framework/run "$FABRIC_API_KEY"
else
	echo "Skipping Fabric configuration..."
fi