#!/bin/bash

swiftlint lint --reporter json \
| jq -r '.[].rule_id' \
| sort \
| uniq -c \
| sort -r
