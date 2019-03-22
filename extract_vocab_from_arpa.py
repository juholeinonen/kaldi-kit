#!/usr/bin/env python3

import sys

in_1grams = False
for line in sys.stdin.buffer:
    if line.startswith(b'\\'):
        if not in_1grams and line.startswith(b"\\1-gram"):
            in_1grams = True
            continue
        if in_1grams:
            break
    if in_1grams:
        parts = line.split()
        if len(parts) >= 2 and len(parts[1].strip()) > 0:
            w = parts[1].strip()
            if w == b'<s>':
                continue
            if w == b'</s>':
                continue

            sys.stdout.buffer.write(parts[1].strip())
            sys.stdout.buffer.write(b'\n')
    
