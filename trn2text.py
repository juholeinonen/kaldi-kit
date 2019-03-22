#!/usr/bin/env python3

from __future__ import print_function
import os
import sys
import unicodedata
from codecs import open

def main(trn_file):
	
	text_name = "text"
	text_file = open(text_name, "w",encoding='utf-8')

	for line in open(trn_file, encoding='utf-8'):
		line = line.rstrip()
		line = line.split('(')
		line_text = line[0]
		line_ID = line[1][:-1]

		text_file.write(line_ID + " ")
		line_text = line_text.rstrip()
		text_file.write(line_text)		
		text_file.write("\n")
	
	text_file.close()



if __name__ == "__main__":
    main(sys.argv[1])


