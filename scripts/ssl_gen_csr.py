#!/usr/bin/env python3

"""Log current aws identity data

"""
import argparse
import logging
import json_logging
import sys


def get_logger(verbose=False):
    # log is initialized without a web framework name
    # log is initialized without a web framework name
    json_logging.init_non_web(enable_json=True)
    if verbose:
        ll = logging.DEBUG
    else:
        ll = logging.INFO

    logger = logging.getLogger(__name__)
    logger.setLevel(ll)
    ch = logging.StreamHandler(sys.stdout)
    ch.setLevel(ll)
    # create file handler which logs even debug messages
    fh = logging.FileHandler("aws_whoami.log")
    fh.setLevel(ll)

    logger.addHandler(ch)
    logger.addHandler(fh)

    return logger


def log_something():
    logger = get_logger()
    stuff_to_log = {"color": "blue", "height": "medium"}
    return stuff_to_log


def aws_user(aws_region="us-east-1"):
    """

    :param str aws_region: ex, us-east-1
    :param str name_tag: tag 'Name'  value to filter on. ex. 'idp_dev_idp'

    :rtype: List[boto3.resources.factory.ec2.Instance]
    """
    import boto3

    session = boto3.Session(region_name=aws_region)
    iam_resource = session.resource("iam")
    current_user = iam_resource.CurrentUser()
    sts_client = session.client("sts")
    return {
        "CURRENT_USER_ID": current_user.user_id,
        "CURRENT_USER_NAME": current_user.user_name,
        "CURRENT_USER_DESC": "Put some real description here. get it from a config file lookup?",
        "CURRENT_ACCOUNT": sts_client.get_caller_identity().get("Account"),
        "CURRENT_ACCOUNT_ID": sts_client.get_caller_identity().get("UserId"),
        "CURRENT_ACCOUNT_ARN": sts_client.get_caller_identity().get("Arn"),
        "CURRENT_ACCOUNT_REGION": session.region_name,
    }


def parse_args(args):
    parser = argparse.ArgumentParser(
        description="Write current aws user account to stdout and log file in json format",
        prog="aws_whoami",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        dest="verbose",
        help="Set log level to debug",
    )


def main():
    import os

    logger = get_logger()

    # Get a argparse.Namespace from the CLI args
    if len(sys.argv) > 0:
        parser = parse_args(sys.argv[1:])
        if getattr(parser, "help", False):
            parser.print_help(sys.stderr)
            return 0
        verbose = getattr(parser, "verbose", False)

    # logger = get_logger(verbose=verbose)
    res = aws_user()
    logger.info("aws_whoami", extra={"props": res})
    logger.info("aws_whoami", extra={"props": log_something()})

    return 0


if __name__ == "__main__":
    sys.exit(main())  # pragma: no cover
