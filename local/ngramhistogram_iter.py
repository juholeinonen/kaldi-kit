#!/usr/bin/env python3

from __future__ import print_function
import os
import sys
import unicodedata
from codecs import open
from itertools import islice

def main(file1, basepath, file3name):
	
	common_name = file3name 
	common_file = open(common_name, "a",encoding='utf-8')
	with open(file1, 'r',encoding='utf-8') as f1:
		while True:
			lines_gen = islice(f1, 1000)
			print("--- iteration ---")
			same = {line.rstrip(): 1 for line in lines_gen} 
			if not same:
				break
			for file2 in os.listdir(basepath):
				if file2.startswith("x0"):
					print(file2)
					with open(file2, 'r',encoding='utf-8') as f2:
						for sentence in f2:
							if sentence.rstrip() in same:
								common_file.write(sentence)
	common_file.close()

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], sys.argv[3])


