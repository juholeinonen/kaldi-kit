#!/usr/bin/env python3

from __future__ import print_function
import os
import sys

def main(basepath):


	for filename in os.listdir(basepath):
		if filename.endswith(".txt") and 'corpus' in filename:
			name_of_file = filename.split('_')
			marking = name_of_file[2]
			perp_name = "corpus_scores_" + marking +"_.txt"
			params = name_of_file[3:]
			params = ''.join(params)
			params = params[:-4]
			a_index = params.index("a")
			D_index = params.index("D")
			alpha = params[a_index+1:D_index]
			if len(alpha) > 1:
				alpha = float(alpha[:1] + '.' + alpha[1:])
			else:
				alpha = float(alpha)
			D = params[D_index+1:]
			if len(D) > 1:
				D = float(float(D[:1] + '.' + D[1:]))
			else:
				D = float(D)
			with open(os.path.join(basepath, filename)) as f:
				for line in f:
					line = line.split(' ')
					if line[0] == 'Perplexity' and line[1][0] != '(':
						perplexity = float(line[1])
						line_to_write = str(alpha) + ' ' + str(D) + ' ' + str(perplexity)
						with open(perp_name, "a") as perplist_file:
							perplist_file.write(line_to_write) 
							perplist_file.write("\n")

if __name__ == "__main__":
	main(sys.argv[1])
