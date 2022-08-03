#!/usr/bin/env python
"""
Generalized command line interface for stage-in.
"""

import os
import sys
import inspect
import argparse
from urllib.parse import urlparse
import requests
import urllib3
import shutil
import logging
import boto3
from botocore import UNSIGNED
from botocore.config import Config
from maap.maap import MAAP


urllib3.disable_warnings()


log_format = "[%(asctime)s: %(levelname)s/%(name)s/%(funcName)s] %(message)s"
logging.basicConfig(format=log_format, level=logging.WARNING)
logger = logging.getLogger('stage_in')


def create_inputs_dir(inputs_dir: str = "inputs") -> str:
    """Create inputs directory."""

    if not os.path.isdir(inputs_dir):
        os.makedirs(inputs_dir)
    return inputs_dir


def stage_in_http(url: str) -> str:
    """Stage in a file from a HTTP/HTTPS URL.

    Args:
        url (str): HTTP/HTTPS URL of input file

    Returns:
        str: relative path to the staged-in input file

    """

    # create inputs directory
    inputs_dir = create_inputs_dir()

    # download input file
    p = urlparse(url)
    staged_file = os.path.join(inputs_dir, os.path.basename(p.path))
    r = requests.get(url, stream=True, verify=False)
    r.raise_for_status()
    r.raw.decode_content = True
    with open(staged_file, "wb") as f:
        shutil.copyfileobj(r.raw, f)

    return staged_file


def stage_in_s3(url: str, unsigned: bool = False) -> str:
    """Stage in a file from an S3 URL.

    Args:
        url (str): S3 URL of input file
        unsigned (bool): send unsigned request

    Returns:
        str: relative path to the staged-in input file

    """

    # create inputs directory
    inputs_dir = create_inputs_dir()

    # download input file
    p = urlparse(url)
    staged_file = os.path.join(inputs_dir, os.path.basename(p.path))
    if unsigned:
        s3 = boto3.client("s3", config=Config(signature_version=UNSIGNED))
    else:
        s3 = boto3.client("s3")
    s3.download_file(p.netloc, p.path[1:], staged_file)

    return staged_file


def stage_in_maap(
    collection_concept_id: str,
    readable_granule_name: str,
    # TODO: remove these commented parameters if there is no need for them
    # user_token: str,
    # application_token: str,
    maap_host: str = "api.ops.maap-project.org",
) -> str:
    """Stage in a MAAP dataset granule.

    Args:
        collection_concept_id (str): the collection-concept-id of the dataset collection
        readable_granule_name (str): either the GranuleUR or producer granule ID
        user_token (str): MAAP user token (retrieved from https://auth.ops.maap-project.org/)
        application_token (str): MAAP application token
        maap_host (str): IP or FQDN of MAAP API host

    Returns:
        str: relative path to the staged-in input file

    """

    # create inputs directory
    inputs_dir = create_inputs_dir()

    # instantiate maap object
    maap = MAAP(maap_host=maap_host)

    # get granule object
    granule = maap.searchGranule(
        collection_concept_id=collection_concept_id,
        readable_granule_name=readable_granule_name,
    )[0]

    # parse url
    url = granule.getDownloadUrl()
    p = urlparse(url)

    # download input file
    staged_file = os.path.join(inputs_dir, os.path.basename(p.path))
    granule.getData(destpath=inputs_dir)

    return staged_file


def dispatch(args):
    """Dispatch to appropriate function."""

    # turn on debugging if specified
    if args.debug:
        logger.setLevel(logging.DEBUG)
    logger.debug("args: %s" % args)

    # dispatch args to the underlying stage-in function
    sig = inspect.signature(args.func)
    logger.debug(f"func: {args.func}")
    logger.debug(f"sig: {sig}")
    return args.func(*[getattr(args, param) for param in sig.parameters])


def main():
    """Process command line."""

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--debug', '-d', action='store_true',
                        help="turn on debugging")
    subparsers = parser.add_subparsers(help='Functions')

    # parser for staging in file from an HTTP/HTTPS URL
    parser_http = subparsers.add_parser('http', help="stage in from HTTP/HTTPS URL")
    parser_http.add_argument('url', help="HTTP/HTTPS URL of the input file")
    parser_http.set_defaults(func=stage_in_http)

    # parser for staging in file from an S3 URL
    parser_s3 = subparsers.add_parser('s3', help="stage in from S3 URL")
    parser_s3.add_argument('url', help="S3 URL of the input file")
    parser_s3.add_argument('--unsigned', '-u', action='store_true', help="send unsigned request")
    parser_s3.set_defaults(func=stage_in_s3)

    # parser for staging in file from an MAAP dataset granule
    parser_maap = subparsers.add_parser('maap', help="stage in MAAP dataset granule")
    parser_maap.add_argument('collection_concept_id', help="the collection-concept-id of the dataset collection")
    parser_maap.add_argument('readable_granule_name', help="either the GranuleUR or producer granule ID")
    # TODO: remove these commented parameters if there is no need for them
    # parser_maap.add_argument('user_token', help="MAAP user token (retrieved from https://auth.ops.maap-project.org/)")
    # parser_maap.add_argument('application_token', help="MAAP application token")
    parser_maap.add_argument('--maap_host', '-m', default='api.ops.maap-project.org', help="IP or FQDN of MAAP API host")
    parser_maap.set_defaults(func=stage_in_maap)

    # parse
    args = parser.parse_args()

    # print help
    if len(sys.argv) == 1 or not hasattr(args, 'func'):
        parser.print_help(sys.stderr)
        sys.exit(1)

    # dispatch to the specified stage-in function and get path to staged-in file
    staged_file = dispatch(args)

    # write out path to staged-in file to STDOUT
    print(staged_file)

    return staged_file

if __name__ == "__main__":
    main()
