#!/usr/bin/env python3

import argparse
import sqlite3
import zlib
from contextlib import closing

import pandas as pd


def build_file(name, contents, ftype):
    handle = '{}.{}'.format(name, ftype)
    with open(handle, 'w') as file:
        file.write(zlib.decompress(contents).decode('utf-8'))


def parse():
    parser = argparse.ArgumentParser()
    parser.add_argument('-o', '--organism', required=True)
    parser.add_argument('-d', '--database', required=True)
    parser.add_argument('-c', '--cluster')
    arguments = parser.parse_args()

    return arguments


if __name__ == '__main__':
    # TODO: Add sampleID_list, date range to query searches
    # initialize variables
    args = parse()

    # connect to the database
    with closing(sqlite3.connect(args.database)) as conn:
        # create cursor
        cursor = conn.cursor()

        # pull data
        data = pd.read_sql_query("SELECT id, assembly, gff, aligned, vcf, cluster, organism FROM intermediate WHERE organism = ?",
                                 conn, params=[args.organism])

        if args.cluster != 'all':
            data = data[data['cluster'] == args.cluster]

        # pull reference genome
        reference = cursor.execute("SELECT sequence FROM reference_genomes WHERE organism = ?",
                                   [args.organism]).fetchall()

        # if the organism is not present, raise an error
        if len(data) == 0:
            message = "Organism '{}' is not present in {}".format(args.organism, args.database)
            raise ValueError(message)

        for row in data.values.tolist():
            build_file(row[0], row[1], 'fasta')
            build_file(row[0], row[2], 'gff')
            build_file(row[0], row[3], 'aligned.fa')
            build_file(row[0], row[4], 'vcf')

        build_file('reference', reference[0][0], 'fna')
