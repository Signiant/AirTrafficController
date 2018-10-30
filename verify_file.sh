#!/bin/bash

PUBLIC_KEY=$1
FILE_TO_VERIFY=$2
SIGNATURE_FILE=$2.sig

HELP_TEXT="Usage: verify_file.sh <public_key> <file_to_verify>"
HELP_TEXT_2="Output: Returns 0 if successful, otherwise 1."

if [ -z "$PUBLIC_KEY" ]; then
    echo $HELP_TEXT
    echo $HELP_TEXT_2
    exit 1
fi

if [ -z "$FILE_TO_VERIFY" ]; then
    echo $HELP_TEXT
    echo $HELP_TEXT_2
    exit 1
fi

if [ ! -s "$PUBLIC_KEY" ]; then
    echo "ATC: ERROR: Public key file '$PUBLIC_KEY' does not exist"
    exit 1
fi

if [ ! -s "$FILE_TO_VERIFY" ]; then
    echo "ATC: ERROR: Input file '$FILE_TO_VERIFY' does not exist"
    exit 1
fi

if [ ! -s "$SIGNATURE_FILE" ]; then
    echo "ATC: ERROR: Cannot find signature file '$SIGNATURE_FILE'"
    exit 1
fi

openssl dgst -sha256 -verify "$PUBLIC_KEY" -signature "$SIGNATURE_FILE" "$FILE_TO_VERIFY"
