# Comparing string processing performance of programming languages

... using a simple bioinformatics task: Computing the GC fraction of DNA.

## Usage

```
make all
cat report.csv
```

## More info

This is a continuation of a previous benchmarking project, covered in [this blog post](http://saml.rilspace.com/moar-languagez-gc-content-in-python-d-fpc-c-and-c).

The idea is to compare the string processing performance of different programming languages
by implementing a very small a very simple algorithm and task: Read a [specific file](http://ftp.ensembl.org/pub/release-67/fasta/homo_sapiens/dna/Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa.gz)
containing DNA sequence in the [FASTA format](https://en.wikipedia.org/wiki/FASTA_format),
and compute the GC content in this file.

Two requirements apply:

1. The file must be read line by line (since DNA files are in reality ofter
   bigger than RAM, and this also helps make the implementations remotely
   comparable)
2. For each line, the program has to check if it starts with a `>` character,
   which if so means it is a header row and should be skipped.

The FASTA file can contain DNA letters (A,C,G,T) or unknowns (N), or new-lines
(Unix style `\n` ones).

This is it. Please have a look in the Makefile, and the various implementations
in the code directories, or send a pull request with your own implementation
(if the language already exists, increase the number one step, so for a new Go
implementation, you would create a `golang.001` folder, optionally with some
tag appended to it, like: `golang.001.table-optimized`, etc).

## Current results

These are some results (Execution times in seconds, smaller is better) from
running the tests in the Makefile, on my Lenovo ThinkPad Yoga with an Intel i5
4210U @ 1.7GHz (2.7GHz Max) and 8GB RAM, on Xubuntu 16.04 LTS 64bit:

| Language  | Execution time (s) | Compiler versions                                                 |
|-----------|--------------------|-------------------------------------------------------------------|
| C         |              0.176 | gcc (Ubuntu 5.4.0-6ubuntu1~16.04.4) 5.4.0 20160609                |
| Go        |              0.240 | go version go1.8 linux/amd64                                      |
| D         |              0.303 | LDC - the LLVM D compiler (0.17.1) (LLVM 3.8.0)                   |
| C++       |              0.380 | g++ (Ubuntu 5.4.0-6ubuntu1~16.04.4) 5.4.0 20160609                |
| Nim       |              0.513 | Nim Compiler Version 0.12.0 (2015-11-02)                          |
| FPC       |              0.517 | Free Pascal Compiler version 3.0.0+dfsg-2 [2016/01/28] for x86_64 |
| PyPy      |              0.520 | PyPy 5.1.2 with Gcc 5.3.1 20160413 (Python 2.7.10)                |
| Cython    |              1.570 | Cython version 0.23.4                                             |
| Python    |              2.217 | Python 3.6.1                                                      |

## Acknowledgements

I got tons of help with the [previous blog post](http://saml.rilspace.com/moar-languagez-gc-content-in-python-d-fpc-c-and-c),
and I'm afraid I might miss to mention some people here who have helped out,
but see the below list as an (incomplete) start at collecting contributors, and
feel free to add any missing info, including yourself, here.

## Incomplete list of contributions

- Daniel Spångberg (working at UPPMAX HPC center at the time) contributed
  numerous, extremely fast implementations in C, including the one above
  (c.000), which is constrained by the requirement to process the file line by
  line.
- [Roger Peppe](https://github.com/rogpeppe)
  ([twitter](https://twitter.com/rogpeppe)) contributed the fastest Go
  implementation, including pointers in combination with a table lookup.
- [Mario Ray Mahardhika (aka leledumbo)](https://github.com/leledumbo)
  contributed the fastest FreePascal implementation, which is the one above
  (fpc.000).
- [Harald Achitz](https://www.linkedin.com/in/harald-achitz-860657139/)
  provided the C++ implementation used above (cpp.000).
- (Who is missing here?)
