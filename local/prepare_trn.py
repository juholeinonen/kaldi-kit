#!/usr/bin/env python3

import sys
#import subprocesses

def main(intermediate_file):
    trn = []
    with open(intermediate_file, "r", encoding="utf-8") as inter:
        for line in inter:
            start, end, *words = line.split()
            print(words)
            trn.append(words)

if __name__ == "__main__":
    main(sys.argv[1])
