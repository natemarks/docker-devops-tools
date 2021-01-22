#!/usr/bin/env python3
import pytest

DOCKER_CMD = "docker run --rm -i devops-tools:latest"
# demonstrate that we can use go to get/build/run
GO_CMD = "set -e;go get github.com/go-training/helloworld;find / -type d -name helloworld -print;go install github.com/go-training/helloworld;find / -type f -name helloworld -print;/root/go/bin/helloworld"


""" Try to run  each of binaries we need in the image

test the exit code for each
"""


@pytest.mark.parametrize(
    "command,exit_code",
    [
        ("{d} /bin/bash -c '{g}'".format(d=DOCKER_CMD, g=GO_CMD),0),
        ("{} jq --version".format(DOCKER_CMD),0),
        ("{} git --version".format(DOCKER_CMD),0),
        ("{} wget --version".format(DOCKER_CMD),0),
        ("{} curl --version".format(DOCKER_CMD),0),
        ("{} aws --version".format(DOCKER_CMD),0),
        ("{} terraform --version".format(DOCKER_CMD),0),
        ("{} terragrunt --version".format(DOCKER_CMD),0),
        ("{} kubergrunt --version".format(DOCKER_CMD),0),
        ("{} packer --version".format(DOCKER_CMD),0),
        ("{} ansible --version".format(DOCKER_CMD),0),
        ("{} python3 --version".format(DOCKER_CMD),0),
        ("{} python --version".format(DOCKER_CMD),0),
        ("{} unzip --version".format(DOCKER_CMD),10),
        ("{} ssh --version".format(DOCKER_CMD),255),
        ("{} /scripts/gen_csr_and_key.sh --help".format(DOCKER_CMD),0),
        ("{} /scripts/tarball_ssl_certs.sh --help".format(DOCKER_CMD),0)
    ],
)
def test_run_binaries(host, command,exit_code):
    cmd = host.run(command)
    assert cmd.rc == exit_code

ANSIBLE_CFG = """[defaults]
remote_tmp     = /tmp/.ansible-${USER}/tmp
"""

@pytest.mark.parametrize(
    "command,exit_code",
    [
        ("{} cat /etc/ansible/ansible.cfg".format(DOCKER_CMD),0),
    ],
)
def test_ansible_cfg(host, command,exit_code):
    cmd = host.run(command)
    assert cmd.rc == exit_code
    assert cmd.stdout == ANSIBLE_CFG