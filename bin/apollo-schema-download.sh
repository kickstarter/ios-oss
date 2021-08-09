#!/bin/sh
npm install -D apollo
npx apollo codegen:generate --endpoint=https://staging.kickstarter.com/graph --target=swift --includes=./**/*.graphql KsApi/graphql-schema.json