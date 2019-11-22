#!/bin/sh

if [ ! -z $DANGER_GITHUB_API_TOKEN ]; then
  bundle exec danger --verbose;
else
  echo "Skipping Danger for External Contributor";
fi
