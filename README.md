# AirTrafficController - Run signed scripts on your cloud instances

AirTrafficController (ATC) is a solution for running BASH and Python based scripts on your cloud instances.  These scripts need to be signed to insure they were not executed arbitrary.

# How It Works
ATC runs as a crontab entry on your instances syncing an AWS bucket/key with a local tmp directory.  The scripts are then checked to see that they have an accompanied signed file to confirm authenticity by decoding the script and making sure it matches. This is a small safeguard to make sure someone hasn't added their own script that should be excuted by the crontab entry.

## Running on a Linux Instance

- Install AWS CLI and configure default profile with a key that has access to your bucket
- Make sure crontab is also installed
- Clone this repository and run deploy_atc.sh script including a location of the release artifact, MD5, and the AWS Scripts bucket and/or key(folder) where the scripts will be located (make sure your public_key is located in /tmp/atc_pub or modify the ATC_PUB_KEY_INSTALL varible with your public_key location for installation)
- Sign scripts using the sign_file.sh script and place script with signed file in bucket
- Watch for execution on 5 minute intervals.


## Running on Elastic Beanstalk with Amazon Linux

- Add the ATC_RELEASE_URL, ATC_RELEASE_MD5, ATC_SCRIPTS_BUCKET environment variables to your Elastic Beanstalk enviroment filling in the correct values.
- Modify the 50_deploy_atc.config to include your public_key you use for signing. (Private key will be used to sign your scripts)
- Add the 50_deploy_atc.config elastic beanstalk extension to your code project that is deployed to your environment.
- Deploy your code with the extension.
- Sign scripts using the sign_file.sh script and place script with signed file in bucket
- Watch for execution on 5 minute intervals.


# Signing scripts
In order for scripts to be executed they must be signed and verified against the public_key that will be included on your instance.

## To sign:
- Generate a RSA public/private key pair (ssh-keygen -t rsa)
- Use the sign_file.sh script inputting the generated private key and the script you want to sign: `sign_file.sh <private_key> <file_to_sign>`
- Put the script along with the generated .sig file into the bucket that ATC will sync from (ATC_SCRIPTS_BUCKET environment variable)
