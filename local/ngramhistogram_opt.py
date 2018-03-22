#!/usr/bin/env python3

from __future__ import print_function
import os
import sys
import unicodedata
from codecs import open

def main(file1, file2):
	
	common_name = "shared_grams.txt"
	common_file = open(common_name, "w",encoding='utf-8')
	with open(file1, 'r',encoding='utf-8') as f1:
		with open(file2, 'r',encoding='utf-8') as f2:
			same = set(f1).intersection(f2)
	same.discard("\n")
	same_list = list(same)
#	for sentence in same_list:
#		common_file.write("%s" % sentence)
	same_list_filtered = list(filter(None, same_list))
	common_file.writelines( "%s" % sentence for sentence in same_list)
	common_file.close()

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])


