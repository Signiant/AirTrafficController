#!/bin/bash

PRIVATE_KEY=$1
FILE_TO_SIGN=$2
OUTPUT_FILE=$2.sig

HELP_TEXT="Usage: sign_file.sh <private_key> <file_to_sign>"
HELP_TEXT_2="Output: <file_to_sign>.sig"

if [ -z "$1" ]; then
    echo $HELP_TEXT
    echo $HELP_TEXT_2
    exit 1
fi

if [ -z "$2" ]; then
    echo $HELP_TEXT
    echo $HELP_TEXT_2
    exit 1
fi

if [ ! -s "$1" ]; then
    echo "ERROR: Private key file '$1' does not exist"
    exit 1
fi

if [ ! -s "$2" ]; then
    echo "ERROR: Input file '$2' does not exist"
    exit 1
fi

openssl dgst -sha256 -sign "${PRIVATE_KEY}" -out "${OUTPUT_FILE}" "${FILE_TO_SIGN}"

if [ $? -ne 0 ]; then
    echo "ERROR: openssl returned with an error. Deleting output file."
    rm $OUTPUT_FILE
    exit 1
fi

echo "Success"
