#!/usr/bin/env python3

from __future__ import print_function
import os
import sys
import unicodedata
from codecs import open

def main(file1, file2, file3name):
	
	common_name = file3name 
	common_file = open(common_name, "w",encoding='utf-8')
	with open(file1, 'r',encoding='utf-8') as f1:
		same = {line: 1 for line in f1} 
		with open(file2, 'r',encoding='utf-8') as f2:
			for sentence in f2:
				if sentence in same:
					common_file.write(sentence)
	common_file.close()

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], sys.argv[3])


