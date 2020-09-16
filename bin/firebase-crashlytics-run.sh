#!/bin/sh

# Copyright 2019 Google
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# run
#
# This script is meant to be run as a Run Script in the "Build Phases" section
# of your Xcode project. It sends debug symbols to symbolicate stacktraces,
# sends build events to track versions, and onboards apps for Crashlytics.
#
# This script calls upload-symbols twice:
#
# 1) First it calls upload-symbols synchronously in "validation" mode. If the
#    script finds issues with the build environment, it will report errors to Xcode.
#    In validation mode it exits before doing any time consuming work.
#
# 2) Then it calls upload-symbols in the background to actually send the build
#    event and upload symbols. It does this in the background so that it doesn't
#    slow down your builds. If an error happens here, you won't see it in Xcode.
#
# You can find the output for the background execution in Console.app, by
# searching for "upload-symbols".
#
# If you want verbose output, you can pass the --debug flag to this script
#

#  Figure out where we're being called from
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#  If the first argument is specified without a dash, treat it as the Fabric API
#  Key and add it as an argument.
if [ -z "$1" ] || [[ $1 == -* ]]; then
  API_KEY_ARG=""
else
  API_KEY_ARG="-a $1"; shift
fi

#  Build up the arguments list, passing through any flags added after the
#  API Key
ARGUMENTS="$API_KEY_ARG $@"
VALIDATE_ARGUMENTS="$ARGUMENTS --build-phase --validate"
UPLOAD_ARGUMENTS="$ARGUMENTS --build-phase"

# Quote the path to handle folders with special characters
COMMAND_PATH="\"$DIR/upload-symbols\" "

#  Ensure params are as expected, run in sync mode to validate,
#  and cause a build error if validation fails
eval $COMMAND_PATH$VALIDATE_ARGUMENTS
return_code=$?

if [[ $return_code != 0 ]]; then
  exit $return_code
fi

#  Verification passed, convert and upload cSYMs in the background to prevent
#  build delays
#
#  Note: Validation is performed again at this step before upload
#
#  Note: Output can still be found in Console.app, by searching for
#        "upload-symbols"
#
eval $COMMAND_PATH$UPLOAD_ARGUMENTS > /dev/null 2>&1 &
