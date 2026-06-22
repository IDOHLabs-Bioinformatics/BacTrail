#!/usr/bin/env python3

import argparse
import pandas as pd


def parse():
    parser = argparse.ArgumentParser()
    parser.add_argument('-s', '--statuses', required=True, type=str)
    args = parser.parse_args()

    return args.statuses[1:-1]


if __name__ == '__main__':
    status = parse()
    status = status.split(', ')

    statuses = pd.DataFrame(columns=['Sample','Organism','Status','Cluster','Number of Other Isolates in the Cluster'])
    for entry in status:
        statuses.loc[len(statuses)] = entry.split(',')

    # convert to int to ensure proper max value determined
    statuses['Number of Other Isolates in the Cluster'] = statuses['Number of Other Isolates in the Cluster'].astype('int')

    statuses['Number of Other Isolates in the Cluster'] = statuses.groupby(['Organism', 'Cluster'])['Number of Other Isolates in the Cluster'].transform('max')

    statuses.to_csv('insert_status.csv', index=False)
