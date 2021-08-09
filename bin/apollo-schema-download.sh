#!/bin/sh
npm install -D apollo
npx apollo codegen:generate --endpoint=https://staging.kickstarter.com/graph KsApi/graphql-schema.json --target=swift --includes=../**/*.graphql