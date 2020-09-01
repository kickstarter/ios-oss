#!/bin/sh

bin/upload-symbols -p 'ios' -gsp ./Frameworks/native-secrets/ios/$1/GoogleService-Info.plist $2 -d
