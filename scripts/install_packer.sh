#!/usr/bin/env bash
# -*- tab-width: 4; encoding: utf-8 -*-

#
# These bash options make the script fragile and verbose. This is ideal for
# pipelines because it can be hard to effectively reproduce the
# pipeline context for troubleshooting. Instead we configure the script to exit
# on the earliest error.
#
# https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html#The-Set-Builtin

# the set -o pipefail causes the script to break at the first failing command
# in a pipeline
#
# The set -u option errors when parameter expansion is performed on an unset
# variable
#
# The set -v option runs the script in verbose mode. it echoes each command
# prior to execution
#
# the set -x (xtrace) echoes each command after performing substitution steps
#

if [[ -z "$BASH" ]]; then
  echo "error: the environment only supports a bash shell"
  exit 1
fi

set -o pipefail
set -u # treat unset variables as error
set -e

#  comment out the set x and v to disable debugging
set -x
set -v

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"