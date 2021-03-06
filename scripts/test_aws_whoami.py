""" Test aws_whoami.py

"""
import pytest
from aws_whoami import parse_args


@pytest.mark.parametrize(
    "argument_list,flag_attribute",
    [(["-v"], "verbose"), (["--verbose"], "verbose")],
)
def test_eval(argument_list, flag_attribute):
    """Positive test the args that set boolean flag values
    Each of these flags should set the flag_attribute to True
    """

    parser = parse_args(argument_list)
    assert getattr(parser, flag_attribute, False)
