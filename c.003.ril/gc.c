/* ================================================
 * Author: Rolf Lampa
 * ================================================ */

#include <stdint.h>
#include <time.h>
#include <stdio.h>
#include <string.h>

typedef int32_t int32;
typedef int8_t byte;

int main(int argc, char* argv[])
{
	const int32 read_size = 512;
	setvbuf(stdout, NULL, _IONBF, read_size);
	FILE *file=fopen("chry_multiplied.fa", "r");

	size_t hit_table[256] = { 0 };
	char line[read_size];

	while (fgets(line, read_size, file))
	{
		if (line[0] == '>') continue;
		char *cp = line;
		while (*cp)
		{
			hit_table[(byte)*cp] += 1;
			*(cp)++;
		}
	}
	fclose(file);

	//-------------------------------------------------------------
	// Collect counters
	//-------------------------------------------------------------
	size_t bases_cnt = 0;
	size_t at_cnt = 0;
	size_t gc_cnt = 0;
	at_cnt = hit_table[(int16_t)'A'] + hit_table[(int16_t)'T'];
	gc_cnt = hit_table[(int16_t)'G'] + hit_table[(int16_t)'C'];
	bases_cnt = gc_cnt + at_cnt;
	double gc_fraction = (gc_cnt * 1.0) / (bases_cnt * 1.0);

	printf("GC Frac  : %f \n", gc_fraction);
	return 0;
}

