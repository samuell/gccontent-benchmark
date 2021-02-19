#include <fstream>
#include <iostream>
#include <stdint.h>

uint64_t value[256] = { 0 };

int main()
{
    std::ifstream f("Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa");
    if (! f.is_open()) return 1;

    value['A'] = value['T'] = 1;
    value['G'] = value['C'] = 1ull << 32;

    uint64_t totals = 0;

    std::string line;
    while (getline(f, line)) {
        const unsigned char *s =
            reinterpret_cast<const unsigned char *>(line.c_str());

        if (*s == '>') continue;

        unsigned char c;
        while ((c = *s++) != '\0')
            totals += value[c];
    }

    double at = totals & 0xFFFFFFFFull;
    double gc = totals >> 32;

    std::cout << gc / (at + gc) * 100.0 << '\n';
    return 0;
}
