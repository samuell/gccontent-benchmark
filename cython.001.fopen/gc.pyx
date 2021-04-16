# cython: boundscheck=False, wraparound=False, initializedcheck=False, cdivision=True

from libc.stdio cimport fopen, fgets, fclose, FILE
from libc.stdint cimport uint64_t


cdef uint64_t value[256];

for i in range(256):
    value[i] = 0;
value[ord('A')] = value[ord('T')] = 1;
value[ord('G')] = value[ord('C')] = 1ull << 32;


cpdef void main():
    cdef FILE*    f
    cdef double   at
    cdef double   gc
    cdef char     line[4096]
    cdef uint64_t totals     = 0
    cdef size_t   i          = 0

    f = fopen("chry_multiplied.fa","r")
    if f == NULL:
        raise OSError("Can't open input file")

    with nogil:

        while fgets(line, sizeof(line), f):
            if line[0] == '>':
                continue
            while line[i] != 0:
                totals += value[line[i]]
                i += 1
            i = 0

        fclose(f)
        at = totals & 0xFFFFFFFFull;
        gc = totals >> 32;

    print( gc / (at + gc) )


if __name__ == '__main__':
    main()
