#!/bin/sh

SDK_NAME=$1
SDK_VERSION=$2
URL=$3
FRAMEWORK_NESTED_PATH=$4
FRAMEWORK_DIR=Frameworks/$SDK_NAME
VERSION_FILE=$FRAMEWORK_DIR/version
CURRENT_SDK_VERSION=first

if [ -e $VERSION_FILE ]; then \
  while read value; do
    CURRENT_SDK_VERSION=$value
  done < $VERSION_FILE
fi

URL=${URL//INSERT_SDK_VERSION/"$SDK_VERSION"}

if [ "$SDK_VERSION" != "$CURRENT_SDK_VERSION" ]; then \
  echo "Downloading $SDK_NAME v$SDK_VERSION"; \
  mkdir -p Frameworks/$SDK_NAME; \
  curl -N -L -o framework.zip $URL; \
  unzip -o framework.zip -d Frameworks/$SDK_NAME; \
  rm framework.zip; \

  if [ ! -z "$FRAMEWORK_NESTED_PATH" ]; then \
    mv Frameworks/$SDK_NAME/$FRAMEWORK_NESTED_PATH/* Frameworks/$SDK_NAME
  fi
fi
if [ -e Frameworks/$SDK_NAME/$SDK_NAME.framework ]; then \
  echo "$SDK_VERSION" > $VERSION_FILE; \
fi
