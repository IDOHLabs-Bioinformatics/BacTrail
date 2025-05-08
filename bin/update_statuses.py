#!/usr/bin/env python3

import argparse


def parse():
    parser = argparse.ArgumentParser()
    parser.add_argument('-s', '--statuses', required=True, type=str)
    args = parser.parse_args()

    return args.statuses[1:-1]


if __name__ == '__main__':
    status = parse()
    status = status.split(', ')
    print(status)

    with open('insert_status.csv', 'w') as out:
        out.write('Sample,Status\n')
        for entry in status:
            out.write(f'{entry}\n')

