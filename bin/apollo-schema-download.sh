#!/bin/sh
curl --location --request POST "https://staging.kickstarter.com/graph" \
  --header "User-Agent: Kickstarter iOS" \
  --header "Authorization: Token ${GRAPHQL_API_AUTH_TOKEN}" \
  --header "Content-Type: application/json" \
  --data-raw "{"query":"{\n  __schema {\n    types {\n      name\n    }\n  }\n}","variables":{}}" > graphql-schema.json
