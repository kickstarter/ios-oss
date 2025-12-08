#!/bin/bash

read -p "Pledge manager URL path (like /projects/foo/bar/redeem): " PM_PATH

read -r -d '' APNS_DATA << EOF
{
    "aps": {
        "alert": "This is a pledge manager push notification.",
    },
    "order": {
        "id": 123456,
        "project_id": 123456,
        "pledge_manager_path": "$PM_PATH"
    }
}
EOF

echo $APNS_DATA
xcrun simctl push booted com.kickstarter.kickstarter.debug - <<< $APNS_DATA
