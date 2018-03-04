#!/usr/bin/env python3

from __future__ import print_function
import os
import sys

def main(basepath):

	wav_name = "wav.scp"
	wavlist_file = open(wav_name, "w")

	utt2spk_name = "utt2spk"
	utt2spk_file = open(utt2spk_name, "w")

	for file in os.listdir(basepath):
		if file.endswith(".wav"):
			line_to_write = " " + basepath + "/"
			name_of_file = file.split('.')
			name_of_file = name_of_file[0]
			wavlist_file.write(name_of_file)
			wavlist_file.write(line_to_write) 
			wavlist_file.write(file)
			wavlist_file.write("\n")
		
			utt2spk_line = name_of_file + " " + name_of_file
			utt2spk_file.write(utt2spk_line) 
			utt2spk_file.write("\n")


	wavlist_file.close()
	utt2spk_file.close()

if __name__ == "__main__":
	main(sys.argv[1])
