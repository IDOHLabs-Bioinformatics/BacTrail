import argparse


def parse():
    parser = argparse.ArgumentParser()
    parser.add_argument('-a', '--assemblies', required=True)

    args = parser.parse_args()
    return args.assemblies


if __name__ == '__main__':
    # initialize variables
    assemblies = parse()
    writing = ''

    with open('popPUNK_query.txt', 'w') as out:
        for assembly in assemblies.split(' '):
            name = assembly.replace('_assembly.fasta', '')
            out.write(f'{name}\t{assembly}\n')
