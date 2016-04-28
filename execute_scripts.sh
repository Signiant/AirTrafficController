#!/bin/bash

HELPTEXT="Usage: execute_scripts.sh <public_key> <path_to_scripts>"
PUBLIC_KEY=$1
FILE_TO_EXECUTE=$2

if [ -z "$1" ]; then
    echo $HELPTEXT
    logger "ATC-$$: Failed to start due to missing arguments"
    exit 1
fi

if [ -z "$2" ]; then
    echo $HELPTEXT
    logger "ATC-$$: Failed to start due to missing arguments"
    exit 1
fi

#Execute bash scripts
for f in ${2}/*.sh
do
  #If none are found then $f == *.sh
  if [ $(basename $f) == "*.sh" ]; then
      logger "ATC-$$: No shell scripts found."
      break
  fi

  ./verify_file.sh $1 $f 2>&1 | logger
  if [ "$?" != 0 ]; then
      logger "ATC-$$: ERROR: Could not verify $f -- skipping execution"
  else
      logger "ATC-$$: Running $f in background..."
      (bash $f; logger "ATC-$$: Deleting $f") &
  fi
done

# Execute python scripts
for f in ${2}/*.py
do
  #If none are found then $f == *.py
  if [ $(basename $f) == "*.py" ]; then
      logger "ATC-$$: No python files found."
      break
  fi
  echo $f
  #Run the verification script against the file
  ./verify_file.sh $1 $f 2>&1 | logger
  if [ "$?" != 0 ]; then
      logger "ATC-$$: ERROR: Could not verify $f -- skipping execution"
  else
      logger "ATC-$$: Running $f in background..."
      (python $f; logger "ATC-$$: Deleting $f") &
  fi
done
