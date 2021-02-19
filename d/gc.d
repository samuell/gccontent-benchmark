import std.stdio;
import std.string;
import std.algorithm;

void main() {
	File file = File("chry_multiplied.fa","r");
    int[256] countat;
    int[256] countgc;
    countat['A'] = 1;
    countat['T'] = 1;
    countgc['G'] = 1;
    countgc['C'] = 1;
    int at = 0;
    int gc = 0;
    char[] line;
    while(file.readln(line)){
		if (startsWith(line, '>')) {
            continue;
        }
        foreach (char c; line) {
            at += countat[c];
            gc += countgc[c];
        }
    }
	float gcFraction = ( cast(float)gc / cast(float)(at+gc) );
    writeln( gcFraction * 100 );
}
