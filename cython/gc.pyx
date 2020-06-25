import re
import string
 
def main():
    file = open("Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa","r")
    cdef int a, t, c, g
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
    cdef int totalBaseCount = a + t + c + g
    cdef int gcCount = g + c
    gcFraction = float(gcCount) / totalBaseCount
    print( gcFraction * 100 )
 
if __name__ == '__main__':
    main()
