#!/bin/sh
npm install -D apollo
npx apollo schema:download --endpoint=https://staging.kickstarter.com/graph KsApi/graphql-schema.json --header "Authorization: token ${GRAPHQL_API_AUTH_TOKEN}" --header "Content-Type: application/json"
