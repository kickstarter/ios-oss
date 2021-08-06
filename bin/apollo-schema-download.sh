#!/bin/sh
npm install -D apollo
npx apollo schema:download --endpoint=https://staging.kickstarter.com/graph --header "Authorization: Token ${GRAPHQL_API_AUTH_TOKEN}" KsApi/graphql-schema.json
