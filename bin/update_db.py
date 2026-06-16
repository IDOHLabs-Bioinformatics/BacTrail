#!/usr/bin/env python3

import argparse

import sqlite3
import zlib
from contextlib import closing


def find_cluster_id(samp_id, cluster_file):
    with open(cluster_file, 'r') as infile:
        for line in infile.readlines():
            info = line.strip().split(',')
            if info[0] == samp_id:
                return info[1]

    raise ValueError("No matching sample ID in popPUNK cluster file.")


def reference_insert(c, organism, ref):
    references = c.execute("SELECT organism FROM reference_genomes").fetchall()
    if (organism,) in references:
        return
    else:
        c.execute("INSERT INTO reference_genomes VALUES (?, ?)", (organism, ref))


def contents(path, compress=True):
    with open(path, 'r') as infile:
        data = infile.readlines()
        data = ''.join(data)

    if compress:
        data = zlib.compress(data.encode('utf-8'), level=7)

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
    parser.add_argument('-c', '--clusters', required=True)
    parser.add_argument('-s', '--collection_date', required=True)
    parser.add_argument('--replace', action='store_true')
    arguments = parser.parse_args()

    return arguments


if __name__ == '__main__':
    # initialize variables
    args = parse()

    # open the database
    with closing(sqlite3.connect(args.db_name)) as conn:
        # create the cursor
        cursor = conn.cursor()

        # make the isolate table if not already there
        if not check_table(cursor, 'isolate_data'):
            cursor.execute(
                "CREATE TABLE isolate_data (ID TEXT PRIMARY KEY, assembly TEXT, gff TEXT, aligned TEXT, vcf TEXT)")
            
        # make the metadata table if not already there
        if not check_table(cursor, 'metadata'):
            cursor.execute(
                "CREATE TABLE metadata (ID TEXT PRIMARY KEY, organism TEXT, cluster TEXT, collection_date TEXT)")

        # make the reference genome table if not already there
        if not check_table(cursor, 'reference_genomes'):
            cursor.execute(
                "CREATE TABLE reference_genomes (organism TEXT PRIMARY KEY, sequence TEXT)")

        # insert data
        try:
            cluster = find_cluster_id(args.id, args.clusters)
            cursor.execute("INSERT INTO isolate_data VALUES (?, ?, ?, ?, ?)",
                           (args.id, contents(args.assembly), contents(args.gff), contents(args.fasta), contents(args.vcf)))
            cursor.execute("INSERT INTO metadata VALUES (?, ?, ?, ?)",
                           (args.id, args.organism, cluster, args.collection_date))
            clusters = cursor.execute("SELECT cluster FROM metadata WHERE organism = ? AND cluster = ?", [args.organism, cluster]).fetchall()
            print(f'{args.id},{args.organism},updated,{cluster},{len(clusters)}')
        except sqlite3.IntegrityError:
            if args.replace:
                cluster = find_cluster_id(args.id, args.clusters)
                cursor.execute("INSERT OR REPLACE INTO isolate_data VALUES (?, ?, ?, ?, ?)",
                           (args.id, contents(args.assembly), contents(args.gff), contents(args.fasta), contents(args.vcf)))
                cursor.execute("INSERT OR REPLACE INTO metadata VALUES (?, ?, ?, ?)",
                           (args.id, args.organism, cluster, args.collection_date))
                clusters = cursor.execute("SELECT cluster FROM metadata WHERE organism = ? AND cluster = ?", [args.organism, cluster]).fetchall()
                print(f'{args.id},{args.organism},overwritten,{cluster},{len(clusters)}')
            else:
                clusters = cursor.execute("SELECT cluster FROM metadata WHERE organism = ? AND cluster = ?", [args.organism, cluster]).fetchall()
                print(f'{args.id},{args.organism},not updated,{cluster},{len(clusters)}')

        # insert reference genome if not present
        reference_insert(cursor, args.organism, contents(args.reference))

        # save the updates
        conn.commit()
