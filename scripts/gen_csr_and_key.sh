#!/usr/bin/env bash

set -Eeuo pipefail

# shellcheck disable=SC2034
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] -d domain -f file

file is the base name of the output files. ex: com_imprivata_cloud_idpadmin

This will generate the files:

 - com_imprivata_cloud_idpadmin.crt
 - com_imprivata_cloud_idpadmin.key


domain is the certificate for the domain, these are valid examples
"idpadmin.cloud.imprivata.com"
"*.beta.common.imprivata.com"

examples:
$(basename "${BASH_SOURCE[0]}") -d "idpadmin.cloud.imprivata.com" -f "com_imprivata_cloud_idpadmin"

$(basename "${BASH_SOURCE[0]}") -d "*.beta.common.imprivata.com" -f "com_imprivata_common_beta_star"

Script description here.

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
-d, --domain    Certificate domain
-f, --file      Base output file name
EOF
  exit
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    # shellcheck disable=SC2034
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

parse_params() {
  # default values of variables set from params
  domain=''
  file=''

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -xv ;;
    --no-color) NO_COLOR=1 ;;
    -d | --domain) # domain name
      domain="${2-}"
      shift
      ;;
    -f | --file) # base name of output files
      file="${2-}"
      shift
      ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done


  # check required params and arguments
  [[ -z "${domain-}" ]] && die "Missing required parameter: domain"
  [[ -z "${file-}" ]] && die "Missing required parameter: file ex.com_imprivata_cloud_idpadmin "

  return 0
}

parse_params "$@"
setup_colors

# script logic here

msg "${RED}Read parameters:${NOFORMAT}"
msg "- domain: ${domain}"
msg "- CSR : ${file}.csr"
msg "- Key : ${file}.key"

CSR_FILE_NAME=/download/$file.csr
KEYFILE_FILE_NAME=/download/$file.key
msg "Generating CSR and key"

openssl req -new -newkey rsa:2048 -nodes -out "$CSR_FILE_NAME" -keyout "$KEYFILE_FILE_NAME" -subj "/C=US/ST=Massachusetts/L=Lexington/O=Imprivata Inc/OU=CloudOps/CN=${domain}"

msg "${GREEN}Check CSR:${NOFORMAT}"
openssl req -text -noout -verify -in "$CSR_FILE_NAME"

msg "${GREEN}Check key:${NOFORMAT}"
openssl rsa -in "$KEYFILE_FILE_NAME" -check | grep 'RSA'

msg "${GREEN}Paste the section below into the CSR field with the provider:${NOFORMAT}"
cat "$CSR_FILE_NAME"