#!/usr/bin/env python

# a simple module to print nicer text

from math import ceil, floor

# line length with padding
line_length = 35

def printLine(text : str) :
    if len(text) < line_length :
        padd = (line_length - (len(text) + 2)) /2.0
        padd_l = "".join(["-" for x in range(floor(padd))])
        padd_r = "".join(["-" for x in range(ceil(padd))])
        print(" ".join([padd_l, text, padd_r]))
    else :
        print(text)

if __name__ == "__main__":
    printLine("printline module")
