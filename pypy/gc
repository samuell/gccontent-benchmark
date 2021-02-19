#!/usr/bin/env pypy
import re
import string
 
def main():
    file = open("chry_multiplied.fa","r")
    a = 0
    t = 0
    g = 0
    c = 0
    for line in file:
        if not line.startswith(">"):
            g += line.count("G")
            c += line.count("C")
            a += line.count("A")
            t += line.count("T")
    totalBaseCount = a + t + c + g
    gcCount = g + c
    gcFraction = float(gcCount) / totalBaseCount
    print( gcFraction * 100 )
 
if __name__ == '__main__':
    main()
