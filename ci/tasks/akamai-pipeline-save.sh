#!/usr/bin/env bash

set -e
set -x

env

echo "$AKAMAI_PIPELINE_EDGERC" > $HOME/.edgerc

git clone akamai-pipeline akamai-pipeline-wip

cd akamai-pipeline-wip

akamai pipeline \
    --section="$AKAMAI_PIPELINE_EDGERC_SECTION" \
    save \
    -p "$AKAMAI_PIPELINE_NAME" \
    "$AKAMAI_PIPELINE_ENV"

./ci/commit-if-changed.sh