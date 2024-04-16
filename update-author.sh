#!/bin/bash
set -x
changed_files=$(gh pr view $PR_NUMBER --json files -q ".files[].path" | grep -v '^.github')
author=$(git log -1 --pretty=%ae)

echo "Author: $author"
echo "$changed_files"

for file in ${changed_files}; do
    if [[ -f "$file" && "${file##*.}" =~ ^(yaml|yml)$i ]]; then
        echo "Updating: $file"
        pwd && ls -lrt
        sed -i "1s/^# Author:.*/# Author: ${author}\n/" ${file} &&
        sed -i "1i# Author: ${author}\n" !~ /^# Author:/ ${file}
        git add ${file}
        git commit -m "chore: insert author name"
        head_branch=$(gh pr view $PR_NUMBER --json headRefName | jq '.headRefName')
        git push origin $head_branch
    else
        echo "Skipping: '$file' is not a YAML file or does not exist."
    fi
done