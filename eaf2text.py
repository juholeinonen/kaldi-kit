#!/usr/bin/env python3

__author__ = 'jpleino1'
import sys

def main(eaf_file):
    fillerWords = {"mm", "ahaa", "a"}
    descriptives = {"stroke", "hold", "retraction", "preparation", ".fp",
    ".bri", ".ct", ".noise", "t-", "p-"}
    transcript = []
    with open(eaf_file) as f:
        for line in f:
            line = line.replace("<", ">")
            lineParts = line.split(">")
            for i in range(len(lineParts)):
                if lineParts[i] == "ANNOTATION_VALUE":
                    words = lineParts[i+1].split(" ")
                    for word in words:
                        if word not in fillerWords and word not in descriptives:
                            transcript.append(word)
                        elif word in fillerWords:
                            transcript.append("SPN")
                    break
    with open('transcript2.txt', 'w') as trn:
        trn.write(" ".join(transcript) + "\n")

if __name__ == "__main__":
    main(sys.argv[1])




