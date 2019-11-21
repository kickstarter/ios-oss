#!/bin/sh

[ ! -z $DANGER_GITHUB_API_TOKEN ] && bundle exec danger --verbose || echo "Skipping Danger for External Contributor"
