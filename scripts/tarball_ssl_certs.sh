#!/usr/bin/env bash

set -Eeuo pipefail

# shellcheck disable=SC2034
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] -c cert_dir -t tarball

cert_dir is path to the directory that contains the ssl certificates and keys.
ex. /home/my/ng/deployment/docker/ng/nginx_reverse_proxy/ssl

tarball is the full path to the output file location.  The output file name
will be ${tar_file}

the tarball file contains no directories, just the certificate and key files so
it's easy to expand it into a target directory for deployment

examples:
$(basename "${BASH_SOURCE[0]}") -c "/my/ssl" -t "/tmp"

This would zip up the files in /my/ssl and pack them into:
/tmp/${tar_file}

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
-c, --cert_dir  Certificate directory
-t, --tar_dir      Base output file name
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
  cert_dir=''
  tar_dir=''
  tar_file='ssl_certificates.tar.gz'

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -xv ;;
    --no-color) NO_COLOR=1 ;;
    -c | --cert_dir) # cert_dir name
      cert_dir="${2-}"
      shift
      ;;
    -t | --tar_dir) # base name of output files
      tar_dir="${2-}"
      shift
      ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done


  # check required params and arguments
  [[ -z "${cert_dir-}" ]] && die "Missing required parameter: cert_dir"
  [[ -z "${tar_dir-}" ]] && die "Missing required parameter: tar_dir )"

  return 0
}

parse_params "$@"
setup_colors

# script logic here

msg "${GREEN}Packing contents of ${cert_dir} into ${tar_dir}/${tar_file}${NOFORMAT}"

tar -czvf "${tar_dir}/${tar_file}" -C "${cert_dir}" .