#!/usr/bin/env python3

__author__ = 'jpleino1'
import collections
import unicodedata
import sys
import csv
from codecs import open

def main():
	reader = csv.reader(open('phone_map.csv', 'r'))
	d = dict(reader)
#	d = {}
#	for row in reader:
#		k, v = row
#		d[k] = v
	print(d)
	print(d["w"])
	print("hello world")
main()
