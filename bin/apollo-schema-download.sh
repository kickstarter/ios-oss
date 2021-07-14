#!/bin/sh
npm install -D apollo
apollo schema:download --endpoint=https://www.kickstarter.com/graph KsApi/graphql-schema.json --header "Authorization: token ${GRAPHQL_API_AUTH_TOKEN}"
