#!/usr/bin/env python3
import re
import sys

for line in sys.stdin:
    try:
        key, val = line.strip().split(None, 1)
    except ValueError:
        key = line.strip()
        val = ""
    if "<w>" in val:
        val = val.lower().replace(" ", "").replace("<w>", " ")
    else:
        val = val.lower().replace("+ +","").replace(" +", "").replace("+ ", "")

    val = val.replace("~", "")
    val = re.sub("\[[a-z]*\]", "", val)
    val = re.sub("#[0-9,]+", "", val)

    print("{} {}".format(key, val, end=""))

