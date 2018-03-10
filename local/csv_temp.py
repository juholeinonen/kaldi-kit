#!/usr/bin/env python3

__author__ = 'jpleino1'
import collections
import unicodedata
import sys
import csv
from codecs import open

def main():
	reader = csv.reader(open('coors.csv', 'r'))
	d = dict(reader)
#	d = {}
#	for row in reader:
#		k, v = row
#		d[k] = v
	print(d)
	print("hello world")
main()
