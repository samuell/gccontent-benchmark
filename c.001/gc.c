#include <stdio.h>
#include <stdint.h>

uint64_t value[256] = { 0 };

int main()
{
    FILE *f = fopen("Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa", "r");
    if (f == NULL) { perror("Can't open input file"); return 1; }

    value['A'] = value['T'] = 1;
    value['G'] = value['C'] = 1ull << 32;

    uint64_t totals = 0;

    char line[4096];
    while (fgets(line, sizeof line, f)) {
        if (line[0] == '>') continue;

        unsigned char *s = (unsigned char *) line;
        unsigned char c;
        while ((c = *s++) != '\0')
            totals += value[c];
    }

    fclose(f);

    double at = totals & 0xFFFFFFFFull;
    double gc = totals >> 32;

    printf("%.10f\n", gc / (at + gc) * 100.0);
    return 0;
}
