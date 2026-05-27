#!/usr/bin/env python3

import os

if __name__ == '__main__':
    files = os.listdir()
    result = [file for file in files if file.find('_fastANI.txt') != -1][0]

    with open(result) as ani:
        top = ani.readline().strip()
    ref_path = top.split('\t')[1]
    print(ref_path)

    with open(ref_path) as ref:
        id_line = ref.readline().strip().split()
    genus = id_line[1]
    species = id_line[2]
    
    print(f'{genus}_{species}')
    