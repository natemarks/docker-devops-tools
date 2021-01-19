#!/bin/bash
# Usage: ssl-util -d DOMAIN -w WILDCARD
# Example: ./ssl-util.sh -d "*.beta.common.imprivata.com" -w y

# Get options to pass into script
# Placehold for other options to use script to perform modulus verification

while getopts m:d:w: option
do
  case "${option}"
    in
    m) MODE=${OPTARG};;
    d) DOMAIN=${OPTARG};;
  esac
done

# Generate CSR and Keyfile
mkdir -p $PWD/ssl-util

DOMAIN_BASENAME=$(echo $DOMAIN | sed 's/\*/star/g' | sed 's/\./_/g')

FOLDER_NAME=$PWD/ssl-util/$DOMAIN_BASENAME/

mkdir $FOLDER_NAME

CSR_FILE_NAME=$FOLDER_NAME/$DOMAIN_BASENAME.csr
KEYFILE_FILE_NAME=$FOLDER_NAME/$DOMAIN_BASENAME.key

openssl req -new -newkey rsa:2048 -nodes -out $CSR_FILE_NAME -keyout $KEYFILE_FILE_NAME -subj "/C=US/ST=Massachusetts/L=Lexington/O=Imprivata Inc/OU=CloudOps/CN=${DOMAIN}"
