#!/usr/bin/env pypy
import string
 
def main():
    file = open("chry_multiplied.fa","rb")
    a = 0
    t = 0
    g = 0
    c = 0
    for line in file:
        if line[0] != b">" and len(line) != line.count(b"N") + 1:
            g += line.count(b"G")
            c += line.count(b"C")
            a += line.count(b"A")
            t += line.count(b"T")
    totalBaseCount = a + t + c + g
    gcCount = g + c
    gcFraction = float(gcCount) / totalBaseCount
    print( gcFraction * 100 )
 
if __name__ == '__main__':
    main()
