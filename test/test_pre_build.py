#!/usr/bin/env python3
import pytest

""" Check for things that should nbe in projet files

"""


@pytest.mark.parametrize(
    "file_path,substring",
    [
        ("./Dockerfile", "WORKDIR /azp"),
        ("./Dockerfile", "ca-certificates"),
        ("./Dockerfile", "molecule"),
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
