#!/bin/bash

CHANGED_FILES=$(gh pr view $PR_NUMBER --json files -q ".files[].path" | grep -v '^.github')
AUTHOR=$(git log -1 --pretty=%ae)

echo "Files updated in this PR: $CHANGED_FILES"

for file in ${CHANGED_FILES}; do
    if [[ -f "$file" && "${file##*.}" =~ ^(yaml|yml)$i ]]; then
        set -x
        echo "Updating: $file"
        sed -i "1s/^# Author:.*/# Author: ${AUTHOR}/" ${file} &&
        sed -i "1i# Author: ${AUTHOR}" !~ /^# Author:/ ${file}
        git add ${file}
        git commit -m "chore: insert author name"
        HEAD_REF=$(gh pr view $PR_NUMBER --json headRefName | jq -r '.headRefName')
        git push origin $HEAD_REF
    else
        echo "Skipping: '$file' is not a YAML file or does not exist."
    fi
done