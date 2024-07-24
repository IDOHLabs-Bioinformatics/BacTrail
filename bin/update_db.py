import argparse

import sqlite3
from contextlib import closing


def contents(path):
    with open(path, 'r') as infile:
        data = infile.readlines()
        data = '\n'.join(data)

    return data


def check_table(c):
    tables = c.execute("SELECT name FROM sqlite_master WHERE type='table'").fetchall()

    if ('intermediate',) in tables:
        return True
    else:
        return False


def parse():
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--db_name', required=True)
    parser.add_argument('-i', '--id', required=True)
    parser.add_argument('-o', '--organism', required=True)
    parser.add_argument('-a', '--assembly', required=True)
    parser.add_argument('-g', '--gff', required=True)
    parser.add_argument('-f', '--fasta', required=True)
    parser.add_argument('-v', '--vcf', required=True)
    arguments = parser.parse_args()

    return arguments


if __name__ == '__main__':
    # initialize variables
    args = parse()

    # open the database
    with closing(sqlite3.connect(args.db_name)) as conn:
        # create the cursor
        cursor = conn.cursor()

        # make the table if not already there
        if not check_table(cursor):
            cursor.execute(
                "CREATE TABLE intermediate (ID TEXT, organism TEXT, assembly TEXT, gff TEXT, aligned TEXT, vcf TEXT)")

        # test insert
        cursor.execute("INSERT INTO intermediate VALUES (?, ?, ?, ?, ?, ?)",
                       (args.id, args.organism, contents(args.assembly),
                        contents(args.gff), contents(args.fasta), contents(args.vcf)))

        # save the updates
        conn.commit()
