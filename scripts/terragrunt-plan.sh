#!/usr/bin/env bash

set -Eeuoxv pipefail

project_dir="${1}" || exit

chmod 400 /root/.ssh/id_*
ls -la /root/.ssh
# add keys to known host insided docker
ssh -vvv -T -oStrictHostKeyChecking=no stash.imprivata.com -p 7999
ssh -vvv -T -oStrictHostKeyChecking=no github.com
cd "${project_dir}"
terragrunt init && terragrunt plan