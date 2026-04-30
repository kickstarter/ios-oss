#!/bin/bash

read -p "Project ID (like 123456): " PID

read -r -d '' APNS_DATA << EOF
{
    "aps": {
        "alert": "This is a push notification about your failed payment.",
    },
    "errored_pledge": {
        "project_id": $PID
    }
}
EOF

echo $APNS_DATA
xcrun simctl push booted com.kickstarter.kickstarter.debug - <<< $APNS_DATA
