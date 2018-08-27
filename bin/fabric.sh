#!/bin/sh

if [ ! -z "$CI" ] && [ ! -z "$FABRIC_API_KEY" ] && [ ! -z "$FABRIC_BUILD_SECRET"]; then
	echo "Configuring Fabric..."
	"${PROJECT_DIR}"/Frameworks/Fabric/Fabric.framework/run "$FABRIC_API_KEY" "$FABRIC_BUILD_SECRET"
else
	echo "Skipping Fabric configuration..."
fi