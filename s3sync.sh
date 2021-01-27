#!/bin/bash

FOLDERS_MAP_FILE=$1

declare -A folders

if [ -z "$VERBOSE" ]; then
  VERBOSE=1
fi

echo "Verbose is $VERBOSE"

echo "Processing paths from $FOLDERS_MAP_FILE"
logger "S3SYNC: Processing paths from $FOLDERS_MAP_FILE"

# Read in the folders from the input file
while read -r line; do
  declare -A folders="$line"

  echo "S3SYNC: Syncing S3:${folders[s3]} => local:${folders[local]}"
  logger "S3SYNC: Syncing S3:${folders[s3]} => local:${folders[local]}"

  CMD="/usr/bin/aws s3 sync s3://${folders[s3]} ${folders[local]}"

  if [ $VERBOSE == 1 ]; then
    logger "Sync command: ${CMD}"
  fi

  OUTPUT=$($CMD)

  if [ $? -eq 0 ] && [ $VERBOSE == 1 ]; then
    echo "S3SYNC: command successful"
  else
    echo "S3SYNC ERROR: on command ${CMD}"
    logger "S3SYNC ERROR: on command: ${CMD}"

  if [[ $OUTPUT == *"download"* ]]; then
    echo "S3SYNC: New/Changed files were downloaded - setting marker"
    logger "S3SYNC: New/Changed files were downloaded - setting marker"
    if [ ! -e "${folders[local]}/updated" ]; then
      touch ${folders[local]}/updated
    fi
  else
    echo "No new/changed files were downloaded"
    logger "No new/changed files were downloaded"
  fi
done < ${FOLDERS_MAP_FILE}
