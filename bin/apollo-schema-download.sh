#!/bin/sh
npm install -D apollo
npx apollo schema:download --endpoint=https://staging.kickstarter.com/graph KsApi/graphql-schema.json --header "Authorization: Basic Y3JlYXRpdmU6c3R1ZHlpbmdhdGV3aW50ZXJmdW5ueQ==" --header "User-Agent: Kickstarter iOS" --header "Content-Type: application/json" --data-raw "{'query':'{\n  __schema {\n    types {\n      name\n    }\n  }\n}','variables':{}}"
