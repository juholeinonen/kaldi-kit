#!/usr/bin/env python3

__author__ = 'jpleino1'

import pympi
import os
import sys

def main(elan_file_path):
    eaf = pympi.Elan.Eaf(elan_file_path)
    filename, file_ext = os.path.splitext(elan_file_path)
    head, tail = os.path.split(elan_file_path)
    transcript_name = filename + ".trn"
    columns = []
    with open(transcript_name, 'w', encoding="utf-8") as trn:
        for tier in eaf.tiers:
            try:
                for start, end, word in eaf.get_annotation_data_for_tier(tier):
                    columns.append([str(start), str(end), word]) 
            except:
                print(tier)
        columns = sorted(columns, key=lambda column: int(column[0]))
        for column in columns:
            trn.write(" ".join(column) + "\n")

if __name__ == "__main__":
    main(sys.argv[1])
