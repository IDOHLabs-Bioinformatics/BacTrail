import requests
import json
import argparse


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-o', '--organism', required=True)
    args = parser.parse_args()

    return args.organism


if __name__ == '__main__':
    # initialize variables
    organism = parse_args()
    organism = organism.replace('_', ' ')
    result = ''
    species_id_url = 'https://chewbbaca.online/NS/api/species/list'

    # get species id
    id_json = requests.get('https://chewbbaca.online/NS/api/species/list')
    data = json.loads(id_json.text)
    for entry in data:
        if entry['name']['value'] == organism:
            result = entry['species']['value'][-1]
            break

    print(result)
