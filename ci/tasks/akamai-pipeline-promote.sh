#!/usr/bin/env bash

set -e
set -x

env

echo "$AKAMAI_PIPELINE_EDGERC" > $HOME/.edgerc

git clone akamai-pipeline akamai-pipeline-wip

cd akamai-pipeline-wip

./ci/needs-promotion.sh && (
    echo "$0: promoting..."

    # Promote and wait (-w) for deployment to complete before
    # proceeding
    akamai pipeline \
        --verbose \
        --section="$AKAMAI_PIPELINE_EDGERC_SECTION" \
        promote \
        -p "$AKAMAI_PIPELINE_NAME" \
        -n "$AKAMAI_PIPELINE_NETWORK" \
        -e "$AKAMAI_PIPELINE_EMAILS" \
        -w \
        --force \
        "$AKAMAI_PIPELINE_ENV"
) || echo "$0: no promotion needed"

./ci/commit-if-changed.sh
