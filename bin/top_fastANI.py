#!/usr/bin/env python3

import os
import sys

if __name__ == '__main__':
    result = sys.argv[1]

    with open(result) as ani:
        top = ani.readline().strip()
    ref_path = top.split('\t')[1]
    print(ref_path)

    with open(ref_path) as ref:
        id_line = ref.readline().strip().split()
    genus = id_line[1]
    species = id_line[2]
    
    print(f'{genus}_{species}')
    