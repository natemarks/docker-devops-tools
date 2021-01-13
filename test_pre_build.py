#!/usr/bin/env python3
import pytest

""" Check for things that should be in project files

"""


@pytest.mark.parametrize(
    "file_path,substring",
    [
        ("./Dockerfile", "WORKDIR /azp"),
        ("./Dockerfile", "ca-certificates"),
        ("./requirements.txt", "molecule"),
        ("./requirements.txt", "ansible"),
        ("./requirements.txt", "awscli"),
        ("./requirements.txt", "bcrypt"),
        ("./requirements.txt", "boto3"),
        ("./requirements.txt", "botocore"),
        ("./requirements.txt", "Jinja2"),
        ("./requirements.txt", "json-logging"),
        ("./requirements.txt", "pytest"),
        ("./requirements.txt", "pytest-testinfra"),
        ("./requirements.txt", "PyYAML"),
        ("./requirements.txt", "yamllint"),
    ],
)
def test_file_contain(host, file_path, substring):
    assert host.file(file_path).contains(substring)


""" Check for things that  should not be in  the project files


"""


@pytest.mark.parametrize(
    "file_path, substring",
    [
        ("./Dockerfile", "DEBIAN_FRONTEND=noninteractive"),
    ],
)
def test_not_in_file(host, file_path, substring):
    assert not host.file(file_path).contains(substring)
