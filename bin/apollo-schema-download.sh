#!/bin/sh
npm install -D apollo
npx apollo schema:download --endpoint=https://staging.kickstarter.com/graph KsApi/graphql-schema.json --header "Authorization: token ${GRAPHQL_API_AUTH_TOKEN}" --header 'User-Agent: Kickstarter iOS' --header 'Content-Type: application/json' --header "Authorization: token ${GRAPHQL_API_AUTH_TOKEN}" --data-raw '{"query":"{\n  __schema {\n    types {\n      name\n    }\n  }\n}","variables":{}}'
