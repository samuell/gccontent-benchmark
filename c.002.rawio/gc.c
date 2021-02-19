#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

uint64_t value[256] = { 0 };

int main(int argc, char **argv)
{
    size_t buflen = (argc > 1)? strtoul(argv[1], NULL, 0) : 32768;
    unsigned char *buffer = malloc(buflen + 1);
    if (buffer == NULL) { perror("Can't allocate buffer"); return 1; }

    int fd = open("Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa", O_RDONLY);
    if (fd < 0) { perror("Can't open input file"); return 1; }

    value['A'] = value['T'] = 1;
    value['G'] = value['C'] = 1ull << 32;

    uint64_t totals = 0;

    int in_header_line = 0;
    ssize_t nread;
    while ((nread = read(fd, buffer, buflen)) > 0) {
        buffer[nread] = '>';

        // If we're part-way through a header line, get back to that mode
        if (in_header_line && buffer[0] != '\n') buffer[0] = '>';
        in_header_line = 0;

        unsigned char *s = buffer;
        for (;;) {
            unsigned char c = *s++;

            if (__builtin_expect(c != '>', 1)) totals += value[c];
            else if (s >= &buffer[nread]) goto read_again;
            else {
                // Skip to the end of the header line
                while ((c = *s++) != '\n')
                    if (c == '>' && s >= &buffer[nread]) {
                        in_header_line = 1;
                        goto read_again;
                    }
            }
        }

        read_again: ;
    }

    free(buffer);
    close(fd);

    double at = totals & 0xFFFFFFFFull;
    double gc = totals >> 32;

    printf("%.10f\n", gc / (at + gc) * 100.0);
    return 0;
}
