import argparse
import sys
import os


def parse():
    parser = argparse.ArgumentParser()
    parser.add_argument('-s', '--schema_dir', required=True)
    parser.add_argument('-t', '--target', required=True)

    return parser.parse_args()


if __name__ == '__main__':
    args = parse()
    target = args.target.lower()
    available = ''
    for dir in os.listdir(args.schema_dir):
        name = dir.lower()
        if name.count(target) != 0:
            available = os.path.join(args.schema_dir, dir)
            break

    if available:
        sys.stdout.write('')
        sys.stderr.write(available)
    else:
        sys.stdout.write(args.target)
        sys.stderr.write('')

