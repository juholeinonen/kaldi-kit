#!/usr/bin/env python3

import sys
import re
#import subprocesses

def main(intermediate_file):
    trn = ""
    repl_dict = {
            "." : " ",
            "!" : "",
            "," : "",
            "-" : "",
            "?" : " ",
            "[" : "",
            "]" : "",
            "§" : ""
            }
    with open(intermediate_file, "r", encoding="utf-8") as inter,\
            open("truetrn.trn", 'w', encoding='utf-8') as trnfile:
        for line in inter:
            start, end, *words = line.split()
            words_str = " ".join(words) + " "
            for org, repl in repl_dict.items():
                words_str = words_str.replace(org, repl)
            trn = trn + words_str
        trn = re.sub(' +', ' ', trn)
        # Bit over zealous (ge) OK but (=ge) is not
        trn = re.sub(r'\([^)]*\)', '', trn)
        trn = trn.lower()
        trnfile.write(trn)

if __name__ == "__main__":
    main(sys.argv[1])
