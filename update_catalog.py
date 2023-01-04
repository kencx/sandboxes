#!/usr/bin/python3.9

import argparse
import datetime
import hashlib
import json
import os
from pathlib import Path
import shutil
import sys

def read_json_file(filename):
    try:
        with open(filename, 'r') as f:
            data = json.load(f)
            return data
    except OSError as err:
        sys.exit(f"FATAL: Cannot open file {filename}: {err}")

def check(filename, checksum, checksum_type):
    BUF_SIZE = 65536
    d = {"sha256": hashlib.sha256(),
         "sha1": hashlib.sha1(),
         "md5": hashlib.md5()}

    h = d[checksum_type]
    if not h:
        raise ValueError(f"Checksum type {checksum_type} not supported")

    with open(filename, 'rb') as f:
        while True:
            data = f.read(BUF_SIZE)
            if not data:
                break
            h.update(data)
    return checksum == h.hexdigest()

def main():
    if not os.path.isfile(args.box):
        sys.exit(f"FATAL: Vagrant box file {args.box} does not exist!")

    metadata = read_json_file(args.catalog)

    versions = metadata["versions"]
    if args.version in versions.__str__():
        sys.exit(f"ERROR: Version {args.version} already exists!")

    # handle file checksum
    if args.checksum.startswith("file://"):
        checksum_path = Path(args.checksum.split("file://")[1])
        try:
            with open(checksum_path, 'r') as f:
                s = f.read()
                checksum = s.split()[0]
        except OSError as err:
            sys.exit(f"FATAL: Cannot read checksum file {args.checksum}: {err}")
    else:
        checksum = args.checksum

    if not check(args.box, checksum, args.checksum_type):
        sys.exit(f"ERROR: {args.checksum_type} checksum for {args.box} invalid!")

    data = {
        "version": args.version,
        "providers": [
            {
                "name": args.provider,
                "url": "file://" + args.box,
                "checksum_type": args.checksum_type,
                "checksum": checksum
            }
        ]
    }
    metadata["versions"].append(data)

    # create backup
    try:
        now = datetime.datetime.now()
        backup = f"{args.catalog}_{now:%y%m%d-%H%M%S}"
        shutil.copy(args.catalog, backup)
    except OSError as err:
        sys.exit(f"FATAL: Cannot create backup of Vagrant catalog metadata file \
            {args.catalog}: {err}"
        )

    try:
        with open(args.catalog, 'w') as f:
            json.dump(metadata, f, indent=2)
    except OSError as err:
        sys.exit(f"FATAL: Cannot write to Vagrant catalog metadata file \
            {args.catalog}: {err}"
        )

    print("INFO: Wrote new metadata successfully!")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Update Vagrant catalog metadata file"
    )
    parser.add_argument("-f", "--catalog",
        required=True,
        type=str,
        help="Full path to catalog metadata file"
    )
    parser.add_argument("-v", "--version",
        type=str,
        help="New box version"
    )
    parser.add_argument("-p", "--provider",
        default="libvirt",
        type=str,
        choices=["libvirt", "virtualbox"],
        help="Box provider"
    )
    parser.add_argument("-b", "--box",
        type=str,
        help="Path to Vagrant box file"
    )
    parser.add_argument("-t", "--checksum_type",
        default="sha256",
        type=str,
        choices=["sha256", "sha1", "md5"],
        help="Checksum type"
    )
    parser.add_argument("-c", "--checksum",
        type=str,
        help="Checksum of box file. Can be string or 'file:///path/to/checksum/file'"
    )
    args = parser.parse_args()

    main()
