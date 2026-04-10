#!/usr/bin/env python3

import argparse
import sqlite3
import zlib
from contextlib import closing
import pandas as pd


def build_ref(name, contents, ftype):
    handle = '{}.{}'.format(name, ftype)
    with open(handle, 'w') as file:
        file.write(zlib.decompress(contents).decode('utf-8'))


def build_file(name, contents, ftype, cluster):
    handle = '{}_cluster_{}.{}'.format(cluster, name, ftype)
    with open(handle, 'w') as file:
        file.write(zlib.decompress(contents).decode('utf-8'))


def parse():
    parser = argparse.ArgumentParser()
    parser.add_argument('--database', required=True, type=str)
    parser.add_argument('--organism', default='', type=str)
    parser.add_argument('--sample_list', default='', type=str)
    parser.add_argument('--cluster', default='', type=str)
    parser.add_argument('--collection_date_start', default='', type=str)
    parser.add_argument('--collection_date_end', default='', type=str)
    arguments = parser.parse_args()

    return arguments


if __name__ == '__main__':
    # initialize variables
    args = parse()

    # connect to the database
    with closing(sqlite3.connect(args.database)) as conn:
        # create cursor
        cursor = conn.cursor()

        # either a sample list is used, or samples are queried
        if args.sample_list != 'any':
            id_list = args.sample_list.split(',')
            placeholders = ','.join(['?'] * len(id_list))

            # pull data
            data1 = pd.read_sql_query(
                f"SELECT ID, assembly, gff, aligned, vcf FROM isolate_data WHERE ID IN ({placeholders})",
                conn, params=id_list)
            data2 = pd.read_sql_query(
                f"SELECT ID, cluster, organism, collection_date FROM metadata WHERE ID IN ({placeholders})",
                conn, params=id_list)
            
            data = data1.merge(data2, left_on='ID', right_on='ID')

            organism = data['organism'].values[0]
            reference = cursor.execute("SELECT sequence FROM reference_genomes WHERE organism = ?",
                                       [organism]).fetchall()
            build_ref('reference', reference[0][0], 'fna')

            for row in data.values.tolist():
                build_file(row[0], row[4], 'fasta', row[1])
                build_file(row[0], row[5], 'gff', row[1])
                build_file(row[0], row[6], 'aligned.fa', row[1])
                build_file(row[0], row[7], 'vcf', row[1])

        elif args.organism != 'any':
            # pull data
            data1 = pd.read_sql_query(
                f"SELECT ID, cluster, organism, collection_date FROM metadata WHERE organism = ?",
                conn, params=[args.organism])
            id_list = data1['ID'].to_list()

            placeholders = ','.join(['?'] * len(id_list))

            data2 = pd.read_sql_query(
                f"SELECT ID, assembly, gff, aligned, vcf FROM isolate_data WHERE ID IN ({placeholders})",
                conn, params=id_list)
            
            data = data1.merge(data2, left_on='ID', right_on='ID')

            # if the organism is not present, raise an error
            if len(data) == 0:
                message = "Organism '{}' is not present in {}".format(args.organism, args.database)
                raise ValueError(message)

            if args.cluster != 'all':
                data = data[data['cluster'] == args.cluster]

                if len(data) == 0:
                    message = "Cluster '{}' is not present in {}".format(args.cluster, args.database)
                    raise ValueError(message)

            data['collection_date'] = pd.to_datetime(data['collection_date'], format='%m-%d-%Y')
            data = data.loc[(data['collection_date'] >= args.collection_date_start) &
                            (data['collection_date'] <= args.collection_date_end)]

            if len(data) == 0:
                message = "There are no isolates in the date range provided ({} - {}) in {}".format(
                    args.collection_date_start, args.collection_date_end, args.database)
                raise ValueError(message)

            # pull reference genome
            reference = cursor.execute("SELECT sequence FROM reference_genomes WHERE organism = ?",
                                       [args.organism]).fetchall()

            for row in data.values.tolist():
                build_file(row[0], row[4], 'fasta', row[1])
                build_file(row[0], row[5], 'gff', row[1])
                build_file(row[0], row[6], 'aligned.fa', row[1])
                build_file(row[0], row[7], 'vcf', row[1])

            build_ref('reference', reference[0][0], 'fna')

        else:
            message = "There is required to be either an organism or reference list provided to query the database."
            raise ValueError(message)
