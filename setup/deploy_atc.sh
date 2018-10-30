#!/bin/bash

HELPTEXT="Usage: deploy_atc.sh <ATC_release_URL> <ATC_zip_md5> <ATC_scripts_bucket_location>"
ATC_URL=$1
ATC_MD5=$2
ATC_S3_LOCATION=$3

if [ -z "$1" ]; then
    echo $HELPTEXT
    logger "ATC-$$: Failed to start due to missing arguments"
    exit 1
fi

ATC_PACKAGE=/tmp/atc.zip
ATC_DIR=/usr/local/signiant-tools/atc
ATC_TMP_DIR=/tmp/atc_scripts
ATC_INSTALL_DIR=/tmp/atc_install
ATC_PUB_KEY_INSTALL=/tmp/atc_pub


if [ -z "$ATC_S3_LOCATION" ]; then
  logger "ATC: ATC_S3_LOCATION beanstalk parameter is not set."
  exit 1
else
  logger "ATC: Pulling scripts from bucket location: $ATC_S3_LOCATION"
fi

if [ ! -d "$ATC_DIR" ]; then
  logger "ATC: Directory $ATC_DIR was not found."
  mkdir $ATC_DIR
fi

wget --output-document=$ATC_PACKAGE $ATC_URL
if [ "$?" -ne 0 ]; then
  logger "ATC: Download failed from $ATC_URL"
  exit 1
fi

echo "$ATC_MD5  $ATC_PACKAGE" > $ATC_PACKAGE.md5

md5sum -c $ATC_PACKAGE.md5
if [ "$?" -ne 0 ]; then
  logger "ATC: Failed md5 verification of $ATC_PACKAGE using md5 $ATC_MD5"
  exit 1
fi

mkdir $ATC_TMP_DIR

chown -R root:root $ATC_TMP_DIR
chown -R root:root $ATC_DIR
cp $ATC_PUB_KEY_INSTALL $ATC_DIR/public_key.pem
chmod -R 700 $ATC_TMP_DIR
chmod -R 700 $ATC_DIR
chmod -R 400 $ATC_DIR/public_key.pem

unzip -o $ATC_PACKAGE -d $ATC_INSTALL_DIR
if [ "$?" -ne 0 ]; then
  logger "ATC: Failed to unzip $ATC_PACKAGE"
  exit 1
fi

#Copy all ATC scripts to atc dir
find $ATC_INSTALL_DIR -name "*.sh" -exec cp -t $ATC_DIR {} +

rm -f $ATC_PACKAGE
rm -rf $ATC_INSTALL_DIR
rm -f $ATC_PUB_KEY_INSTALL
logger "ATC: Removed downloaded package"

echo "( [s3]=${ATC_S3_LOCATION} [local]=/tmp/atc_scripts )" > ${ATC_DIR}/s3sync.dat

exit 0
