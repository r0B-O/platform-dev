#!/bin/bash

changed_files=$(gh pr view $PR_NUMBER --json files -q ".files[].path" | grep -v '^.github')
author=$(git log -1 --pretty=%ae)

echo "Author: $author"
echo "$changed_files"

for file in ${changed_files}; do
  echo "Updating: $file"
  sed -i "1s/^# Author:.*/# Author: ${author}\n/" ${file}
  sed -i "1i# Author: ${author}\n" !~ /^# Author:/ ${file}
  git add ${file}
  git commit -m "Add author comment"
done