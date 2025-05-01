#!/usr/bin/env python3

import os
import argparse
import sys


def is_similar(organism_name, directory):
    lower_name = organism_name.replace(' ', '_').lower()
    lower_dir = directory.lower()

    if lower_name == lower_dir:
        return True
    elif lower_dir.count(lower_name) == 1:
        return True
    elif lower_name.count(lower_dir) == 1:
        return True
    else:
        return False


def parse():
    parser = argparse.ArgumentParser()
    parser.add_argument('-s', '--schema_dir', required=True)
    parser.add_argument('-o', '--organism', required=True)

    args = parser.parse_args()
    return args.schema_dir, args.organism


if __name__ == '__main__':
    # initialize variables
    schema_dir, organism = parse()
    found = False

    # verify schema_dir exits
    if not os.path.isdir(schema_dir):
        raise ValueError("The provided schema directory does not exist.")

    files = os.listdir(schema_dir)

    for file in files:
        if is_similar(organism, file):
            found = True
            print(file)

    if not found:
        raise ValueError(f"The schema is not found for {organism}. Ensure that it is present and named identifiably.")

    sys.exit(0)
