#!/bin/sh
npm install -D apollo@2.11.1
npx apollo schema:download --header="Content-Type: application/json" --header="User-Agent: Kickstarter iOS" --endpoint="https://staging.kickstarter.com/graph" KsApi/graphql-schema.json