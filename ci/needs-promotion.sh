#!/usr/bin/env bash

ENV_INFO="$AKAMAI_PIPELINE_NAME"/environments/"$AKAMAI_PIPELINE_ENV"/envInfo.json

UPPERCASE_NETWORK=$(echo $AKAMAI_PIPELINE_NETWORK | tr 'a-z' 'A-Z')

LATEST_VERSION=$(jq -r .latestVersionInfo.propertyVersion < $ENV_INFO)
LATEST_STATUS=$(jq -r .latestVersionInfo.${AKAMAI_PIPELINE_NETWORK}Status < $ENV_INFO)
ACTIVE_VERSION=$(jq -r .activeIn_${UPPERCASE_NETWORK}_Info.propertyVersion < $ENV_INFO)

echo $LATEST_VERSION $LATEST_STATUS $ACTIVE_VERSION
if [ "$LATEST_VERSION" = "$ACTIVE_VERSION" ];
then
    exit 2
elif [ "$LATEST_STATUS" = "PENDING" ]
then
    exit 1
else
    exit 0
fi
