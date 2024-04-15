#!/bin/bash
PR_NUMBER=7

# Capture JSON from gh command, remove newlines, and write to temporary file
gh pr view $PR_NUMBER --json files -q ".[]" | tr -d '\n' > tmp.json

# Extract desired data (file paths) using jq and write to final JSON file
jq -r '.[].path' tmp.json > changed_files.json

# Cleanup temporary file
rm tmp.json