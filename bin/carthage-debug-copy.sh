#!/bin/sh

if [ "$CONFIGURATION" == "Debug" ]; then
  /usr/local/bin/carthage copy-frameworks
else
  cd "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/"
  if [[ -d "Frameworks" ]]; then 
    rm -fr Frameworks
  fi
fi
