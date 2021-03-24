#!/usr/bin/env bash

set -Eeuoxv pipefail

project_dir="${1}" || exit

chmod 400 /root/.ssh/id_*
# add keys to known host insided docker
ssh-keyscan -p 7999 stash.imprivata.com > /root/.ssh/known_hosts || true
ssh-keyscan github.com >> /root/.ssh/known_hosts || true
chmod 644 /root/.ssh/known_hosts
ls -la /root/.ssh
cat /root/.ssh/known_hosts
cd "${project_dir}"
terragrunt init && terragrunt plan