#!/usr/bin/env python3
import pytest

DOCKER_CMD = "docker run --rm -i devops-tools:latest"
GO_CMD = "set -e;go get github.com/go-training/helloworld;find / -type d -name helloworldddd -print;go install github.com/go-training/helloworld;find / -type f -name helloworld -print;/root/go/bin/helloworld"

""" Run commands and check exit code

"""


@pytest.mark.parametrize(
    "command",
    [
        ("{} jq --version".format(DOCKER_CMD)),
        ("{} git --version".format(DOCKER_CMD)),
        ("{} wget --version".format(DOCKER_CMD)),
        ("{} curl --version".format(DOCKER_CMD)),
        ("{} aws --version".format(DOCKER_CMD)),
        ("{} terraform --version".format(DOCKER_CMD)),
        ("{} terragrunt --version".format(DOCKER_CMD)),
        ("{} kubergrunt --version".format(DOCKER_CMD)),
        ("{} packer --version".format(DOCKER_CMD)),
        ("{} ansible --version".format(DOCKER_CMD)),
        ("{} python3 --version".format(DOCKER_CMD)),
        ("{} python --version".format(DOCKER_CMD)),
        ("{}    ".format(DOCKER_CMD))
    ],
)
def test_file_contain(host, command):
    cmd = host.run(command)
    assert cmd.rc == 0


""" Stupid unzip returns exit code 10 when you run unzip --version
"""


@pytest.mark.parametrize(
    "command",
    [
        ("{} unzip --version".format(DOCKER_CMD)),
    ],
)
def test_unzip_version(host, command):
    cmd = host.run(command)
    assert cmd.rc == 10
