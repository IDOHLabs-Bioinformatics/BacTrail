import argparse

import sqlite3
from contextlib import closing


def reference_insert(c, organism, ref):
    references = c.execute("SELECT organism FROM reference_genomes").fetchall()
    if (organism,) in references:
        return
    else:
        c.execute("INSERT INTO reference_genomes VALUES (?, ?)", (organism, ref))


def contents(path):
    with open(path, 'r') as infile:
        data = infile.readlines()
        data = ''.join(data)

    return data


def check_table(c, tname):
    tables = c.execute("SELECT name FROM sqlite_master WHERE type='table'").fetchall()

    if (tname,) in tables:
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
    parser.add_argument('-r', '--reference', required=True)
    arguments = parser.parse_args()

    return arguments


if __name__ == '__main__':
    # initialize variables
    args = parse()

    # open the database
    with closing(sqlite3.connect(args.db_name)) as conn:
        # create the cursor
        cursor = conn.cursor()

        # make the intermediate table if not already there
        if not check_table(cursor, 'intermediate'):
            cursor.execute(
                "CREATE TABLE intermediate (ID TEXT PRIMARY KEY, organism TEXT, assembly TEXT, gff TEXT, aligned TEXT, vcf TEXT)")

        # make the reference genome table if not already there
        if not check_table(cursor, 'reference_genomes'):
            cursor.execute(
                "CREATE TABLE reference_genomes (organism TEXT PRIMARY KEY, sequence TEXT)")

        # insert data
        cursor.execute("INSERT INTO intermediate VALUES (?, ?, ?, ?, ?, ?)",
                       (args.id, args.organism, contents(args.assembly),
                        contents(args.gff), contents(args.fasta), contents(args.vcf)))

        # insert reference genome if not present
        reference_insert(cursor, args.organism, contents(args.reference))

        # save the updates
        conn.commit()
