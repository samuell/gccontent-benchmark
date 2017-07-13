import std.stdio;
import std.string;
import std.algorithm;

void main() {
	File file = File("Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa","r");
    int countat[256];
    int countgc[256];
    countat['A'] = 1;
    countat['T'] = 1;
    countgc['G'] = 1;
    countgc['C'] = 1;
    int at = 0;
    int gc = 0;
    char[] line;
    while(file.readln(line)){
		if (!startsWith(line, '>')) {
            foreach (char c; line) {
                at += countat[c];
                gc += countgc[c];
            }
        }
    }
	float gcFraction = ( cast(float)gc / cast(float)(at+gc) );
    writeln( gcFraction * 100 );
}
