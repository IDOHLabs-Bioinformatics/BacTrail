#!/usr/bin/env python3

import argparse
import sqlite3
import zlib
from contextlib import closing


def build_file(name, contents, ftype):
    handle = '{}.{}'.format(name, ftype)
    with open(handle, 'w') as file:
        file.write(zlib.decompress(contents).decode('utf-8'))


def parse():
    parser = argparse.ArgumentParser()
    parser.add_argument('-o', '--organism', required=True)
    parser.add_argument('-d', '--database', required=True)
    args = parser.parse_args()

    return args.organism, args.database


if __name__ == '__main__':
    # TODO: Add cluster, sampleID_list to query searches
    # initialize variables
    organism, database = parse()

    # connect to the database
    with closing(sqlite3.connect(database)) as conn:
        # create cursor
        cursor = conn.cursor()

        # pull data
        data = cursor.execute("SELECT id, assembly, gff, aligned, vcf FROM intermediate WHERE organism = ?",
                              [organism]).fetchall()

        # pull reference genome
        reference = cursor.execute("SELECT sequence FROM reference_genomes WHERE organism = ?", [organism]).fetchall()

        # if the organism is not present, raise an error
        if len(data) == 0:
            message = "Organism '{}' is not present in {}".format(organism, database)
            raise ValueError(message)

        for row in data:
            build_file(row[0], row[1], 'fasta')
            build_file(row[0], row[2], 'gff')
            build_file(row[0], row[3], 'aligned.fa')
            build_file(row[0], row[4], 'vcf')

        build_file('reference', reference[0][0], 'fna')
