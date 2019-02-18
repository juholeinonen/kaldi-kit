#!/usr/bin/env python3

__author__ = 'jpleino1'
import sys
import re
import subprocess

def main(text_file):
    with open(text_file, 'r', encoding='utf-8') as text,\
        open("reverse_text", 'w', encoding='utf-8') as r_text,\
        open("utt2spk", 'w',) as utt2spk:
        for line in text:
            if re.match(r'^\s*$', line):
                next
            line = line.strip()
            words = line.split(' ')
            identifier = 'r' + words[0]
            reversed_sentence = " ".join([word[::-1] for word in words[:0:-1]])
            new_line = identifier + " " + reversed_sentence
            r_text.write(new_line + "\n")
            utt2spk.write(identifier + " " + identifier + "\n")
    subprocess.run(["cp", "utt2spk", "spk2utt"])

if __name__ == "__main__":
    main(sys.argv[1])
