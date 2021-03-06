import pytest

from aws_whoami import log_something


def test_log_something():
    res = log_something()
    assert res["color"] == "blue"
