#!/usr/bin/env bash

set -e
set -x

git config user.email "$GIT_EMAIL"
git config user.name "$GIT_NAME"

# Only commit changes if they reflect an actual change
# (other changes might include the log files at the root).
# If we don't do this check, CI will continuously commit and push,
# which will continuously trigger the job, ad infinitum.
git status -s | grep -q "$AKAMAI_PIPELINE_NAME" && (
    git status -s
    git add -A .
    git commit -m "akamai pipeline save $AKAMAI_PIPELINE_NAME / $AKAMAI_PIPELINE_ENV"
) || (
    echo "$0: no meaningful changes to commit"
    # Make sure the repository is clean so the repo can be rebased safely
    git reset --hard origin/master
)
