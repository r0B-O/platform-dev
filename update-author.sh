#!/bin/bash

CHANGED_FILES=$(gh pr view $PR_NUMBER --json files -q ".files[].path" | grep -v '^.github')
AUTHOR=$(git log -1 --pretty=%ae)

echo "Files updated in this PR: $CHANGED_FILES"

for FILE in ${CHANGED_FILES}; do
    if [[ -f "$FILE" && "${FILE##*.}" =~ ^(yaml|yml)$i ]]; then
        set -x
        echo "Checking: $FILE"
        if IFS= read -r firstline < "$FILE" && [[ $firstline = '# Author:'* ]]
        then
            echo 'The file %s contains Author\n' "$FILE"
            echo "Updating author details with commit author - ${AUTHOR}"
            sed -i "1s/^# Author:.*/# Author: r0B-O/" ${FILE}
        else
            echo 'No author details found. Inserting, updating author\n'
            sed -i "1i# Author: r0B-O" !~ /^# Author:/ ${FILE}
        fi
        git add ${FILE}
        git commit -m "chore: insert author name"
        HEAD_REF=$(gh pr view $PR_NUMBER --json headRefName | jq -r '.headRefName')
        git push origin $HEAD_REF
    else
        echo "Skipping: '$FILE' is not a YAML file or does not exist."
    fi
done