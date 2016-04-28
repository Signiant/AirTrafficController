#!/bin/bash

HELPTEXT="Usage: atc.sh <public_key> <path_to_scripts>"
PUBLIC_KEY=$1
FILE_TO_EXECUTE=$2

if [ -z "$1" ]; then
    echo $HELP_TEXT
    exit 1
fi

if [ -z "$2" ]; then
    echo $HELP_TEXT
    exit 1
fi

#Execute bash scripts
for f in ${2}/*.sh
do
  ./verify_file.sh $1 $f
  if [ $? -ne 0 ]; then
      logger "ATC: ERROR: Could not verify $f -- skipping execution"
  else
      logger "ATC: Running $f in background..."
      bash $f &
  fi
done

# Execute python scripts
for f in ${2}/*.py
do
  ./verify_file.sh $1 $f
  if [ $? -ne 0 ]; then
      logger "ATC: ERROR: Could not verify $f -- skipping execution"
  else
      logger "ATC: Running $f in background..."
      python $f &
  fi
done
