#!/bin/sh

bin/upload-symbols -p 'ios' -gsp ./Frameworks/native-secrets/ios/$1/GoogleService-Info.plist ${FL_OUTPUT_DIR}/gym/$2 -d
