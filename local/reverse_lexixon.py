#!/usr/bin/env python3

__author__ = 'jpleino1'
import collections
import unicodedata
import sys
from codecs import open

def main(corpus_file):
	c = collections.Counter()
	for line in open(corpus_file, encoding='utf-8'):
		for word in line.split():
			c[word] += 1
	# dir(c)
	n = 0
	words_more_than_n = [k for k,v in c.items() if v > n]
	words_more_than_n.sort()
	dic_name = "lexicon.txt"
	dictionary_more_than_n = open(dic_name, "w",encoding='utf-8')
	
	dictionary_more_than_n.write(u"!SIL SIL\n")
	dictionary_more_than_n.write(u"<UNK> SPN\n")
	for word in words_more_than_n:
		line = word
		line = unicodedata.normalize(u'NFC', line)
		if line.isdecimal() or line[1:].isdecimal() or line[:-1].isdecimal() or line[1:-1].isdecimal():
			continue
		dictionary_more_than_n.write(line)
		for letter in line:
			if letter != '+':
				dictionary_more_than_n.write(u" " + 'r' + letter)
		dictionary_more_than_n.write(u"\n")
	
	dictionary_more_than_n.close()

if __name__ == "__main__":
    main(sys.argv[1])
