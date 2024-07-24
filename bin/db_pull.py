import sys
import argparse
import sqlite3
from contextlib import closing


def build_file(name, contents, ftype):
    handle = '{}.{}'.format(name, ftype)
    with open(handle, 'w') as file:
        file.write(contents)


def parse():
    parser = argparse.ArgumentParser()
    parser.add_argument('-o', '--organism', required=True)
    parser.add_argument('-d', '--database', required=True)
    args = parser.parse_args()

    return args.organism, args.database


if __name__ == '__main__':
    # initialize variables
    organism, database = parse()

    # connect to the database
    with closing(sqlite3.connect(database)) as conn:
        # create cursor
        cursor = conn.cursor()

        # pull data
        data = cursor.execute("SELECT id, assembly, gff, aligned, vcf FROM intermediate WHERE organism = ?",
                              [organism]).fetchall()
        for row in data:
            build_file(row[0], row[1], 'fasta')
            build_file(row[0], row[2], 'gff')
            build_file(row[0], row[3], 'aln')
            build_file(row[0], row[4], 'vcf')

    print(row[0])
