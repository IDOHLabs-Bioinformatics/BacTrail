#!/usr/bin/env python3

import argparse


def parse():
    parser = argparse.ArgumentParser()
    parser.add_argument('-a', '--assemblies', required=True)
    parser.add_argument('-o', '--organism', required=True)

    args = parser.parse_args()
    return args.assemblies, args.organism


if __name__ == '__main__':
    # initialize variables
    assemblies, organism = parse()
    writing = ''
    handle = organism + '_popPUNK_query.txt'

    with open(handle, 'w') as out:
        for assembly in assemblies.split(' '):
            name = assembly.replace('_assembly.fasta', '')
            out.write(f'{name}\t{assembly}\n')
