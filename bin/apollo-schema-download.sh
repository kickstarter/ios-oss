#!/bin/sh
npm install -D apollo
npx apollo schema:download --endpoint=https://staging.kickstarter.com/graph KsApi/graphql-schema.json