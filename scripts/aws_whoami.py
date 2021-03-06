#!/usr/bin/env python3

""" Log aws account information to stdout and log file in json format

A convenient example of a python utility script on the image

"""
import argparse
import logging
import sys
import boto3
import json_logging


def get_logger(verbose=False):
    """return a logger object
    :rtype: logging.Logger
    """
    json_logging.init_non_web(enable_json=True)
    if verbose:
        log_level = logging.DEBUG
    else:
        log_level = logging.INFO

    logger = logging.getLogger(__name__)
    logger.setLevel(log_level)
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(log_level)
    # create file handler which logs even debug messages
    file_handler = logging.FileHandler("aws_whoami.log")
    file_handler.setLevel(log_level)

    logger.addHandler(console_handler)
    logger.addHandler(file_handler)

    return logger


def aws_user(aws_region="us-east-1"):
    """

    :param str aws_region: ex, us-east-1
    :param str name_tag: tag 'Name'  value to filter on. ex. 'idp_dev_idp'

    :rtype: List[boto3.resources.factory.ec2.Instance]
    """

    session = boto3.Session(region_name=aws_region)
    iam_resource = session.resource("iam")
    current_user = iam_resource.CurrentUser()
    sts_client = session.client("sts")
    return {
        "CURRENT_USER_ID": current_user.user_id,
        "CURRENT_USER_NAME": current_user.user_name,
        "CURRENT_USER_DESC": "Put some real description here",
        "CURRENT_ACCOUNT": sts_client.get_caller_identity().get("Account"),
        "CURRENT_ACCOUNT_ID": sts_client.get_caller_identity().get("UserId"),
        "CURRENT_ACCOUNT_ARN": sts_client.get_caller_identity().get("Arn"),
        "CURRENT_ACCOUNT_REGION": session.region_name,
    }


def parse_args(args):
    """Parse cli arguments"""
    parser = argparse.ArgumentParser(
        description="Write current aws user account to stdout and log file in json format",
        prog="aws_whoami.py",
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        dest="verbose",
        help="Set log level to debug",
    )
    return parser.parse_args(args)


def main():
    """Main"""
    logger = get_logger()
    parser = parse_args(sys.argv[1:])

    verbose = getattr(parser, "verbose", False)
    if verbose:
        logger.setLevel(logging.DEBUG)

    res = aws_user()
    logger.info("aws_whoami", extra={"props": res})

    return 0


if __name__ == "__main__":
    sys.exit(main())  # pragma: no cover
