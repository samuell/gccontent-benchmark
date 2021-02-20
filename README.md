# Comparing string processing performance of programming languages

... using a simple bioinformatics task: Computing the GC fraction of DNA. It is based on the [GC content problem at Rosalind](http://rosalind.info/problems/gc/).

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

## Results<a name="current-results">

These are some results (Execution times in seconds, smaller is better) from
running some of the tests in the Makefile, on a Dell Inspiron laptop with an
Intel(R) Core(TM) i7-8650U CPU @ 1.90GHz, with Xubuntu 18.04 Bionic LTS 64bit
as operating system.

(Below the tables are some more details about BIOS settings etc).

| Language                                                                                                      | Execution Time (s) | Compiler or interpreter version                                                         |
|---------------------------------------------------------------------------------------------------------------|--------------------|-----------------------------------------------------------------------------------------|
| [rust.002.bitshift](rust.002.bitshift/src/main.rs)&nbsp;H/T&nbsp;[@sstadick](https://github.com/sstadick)                   | 0.784              | rustc 1.52.0-nightly (152f66092 2021-02-17)                                             |
| [rust.003.vectorized](rust.003.vectorized/src/main.rs)&nbsp;H/T&nbsp;[@sstadick](https://github.com/sstadick) | 0.853              | rustc 1.52.0-nightly (152f66092 2021-02-17)                                             |
| [rust.001](rust.001/src/main.rs)&nbsp;H/T&nbsp;[@sstadick](https://github.com/sstadick)                       | 0.961              | rustc 1.52.0-nightly (152f66092 2021-02-17)                                             |
| [c.001](c.001/gc.c)&nbsp;H/T&nbsp;[@jmarshall](https://github.com/jmarshall)                                  | 0.97               | gcc (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0                                                 |
| [cpp.001](cpp.001/gc.cpp)&nbsp;H/T&nbsp;[@jmarshall](https://github.com/jmarshall)                            | 1.025              | g++ (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0                                                 |
| [d](d/gc.d)                                                                                                   | 1.215              | LDC - the LLVM D compiler (1.22.0): based on DMD v2.092.1                               |
| [c](c/gc.c)                                                                                                   | 1.226              | gcc (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0                                                 |
| [go.001.unroll](go.001.unroll/gc.go)&nbsp;H/T&nbsp;[@egonelbre](https://github.com/egonelbre)                 | 1.616              | go version go1.15 linux/amd64                                                           |
| [rust](rust/src/main.rs)&nbsp;H/T&nbsp;[@rob-p](https://github.com/rob-p)                                     | 1.722              | rustc 1.52.0-nightly (152f66092 2021-02-17)                                             |
| [julia](julia/gc.jl)&nbsp;H/T&nbsp;[@dcjones](https://github.com/dcjones)                                     | 1.926              | julia version 1.5.3                                                                     |
| [go](go/gc.go)                                                                                                | 1.937              | go version go1.15 linux/amd64                                                           |
| [pypy](pypy/gc.py)&nbsp;H/T&nbsp;[@nh13](https://github.com/nh13)                                             | 2.679              | Python 2.7.13 (5.10.0+dfsg-3build2, Feb 06 2018, 18:37:50) [PyPy 5.10.0 with GCC 7.3.0] |
| [cpp](cpp/gc.cpp)                                                                                             | 2.832              | g++ (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0                                                 |
| [crystal.001.csp](crystal.001.csp/gc.cr)                                                                      | 4.198              | Crystal 0.35.1 [5999ae29b] (2020-06-19)  LLVM: 8.0.0                                    |
| [crystal](crystal/gc.cr)                                                                                      | 4.48               | Crystal 0.35.1 [5999ae29b] (2020-06-19)  LLVM: 8.0.0                                    |
| [nim](nim/gc.nim)                                                                                             | 4.498              | Nim Compiler Version 0.17.2 (2018-02-05) [Linux: amd64]                                 |
| [cython](cython/gc.pyx)&nbsp;H/T&nbsp;[@nh13](https://github.com/nh13)                                        | 6.03               | Cython version 0.26.1                                                                   |
| [fpc](fpc/gc.pas)                                                                                             | 6.578              | Free Pascal Compiler version 3.0.4+dfsg-18ubuntu2 [2018/08/29] for x86_64               |
| [perl](perl/gc.pl)&nbsp;H/T&nbsp;[@sstadick](https://github.com/sstadick)                                     | 7.323              | Perl 5, version 26, subversion 1 (v5.26.1) built for x86_64-linux-gnu-thread-multi      |
| [python](python/gc.py)&nbsp;H/T&nbsp;[@nh13](https://github.com/nh13)                                         | 8.847              | Python 3.7.0                                                                            |

## Results with relaxed constraints on reading line-by-line

The below contributed versions departs slightly from reading line-by-line (by
some definition of that requirement, which is clearly very hard to define):

| Language                                                                                       | Execution time (s) | Compiler versions                       |
|------------------------------------------------------------------------------------------------|-------------------:|-----------------------------------------|
| [C.002.rawio](c.002.rawio/gc.c)<br>H/T [@jmarshall](https://github.com/jmarshall)              |              0.040 | gcc (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0 |

## More details about settings used when benchmarking

The following CPU options were turned off in BIOS, to try to avoid fluctuating
CPU clock frequencies:

- Performance > Intel SpeedStep
- Performance > C-States Control
- Performance > Intel TurboBoost
- Power Management > Intel Speed Shift Technology

Benchmarking was done with other GUI apps, networking and bluetooth turned off.

## Incomplete list of contributions before merge to GitHub

For contributors after establishing the GitHub repo, see [here](https://github.com/samuell/gccontent-benchmark/graphs/contributors).
Below is an incomplete list of people who contributed to the code examples
while the benchmark was [hosted on my old blog](https://github.com/samuell/gccontent-benchmark/graphs/contributors):

- Daniel Spångberg (working at UPPMAX HPC center at the time) contributed
  numerous, extremely fast implementations in C, including the one above (c),
  which is constrained by the requirement to process the file line by line.
- [Roger Peppe](https://github.com/rogpeppe)
  ([twitter](https://twitter.com/rogpeppe)) contributed the fastest Go
  implementation, including pointers in combination with a table lookup.
- [Mario Ray Mahardhika (aka leledumbo)](https://github.com/leledumbo)
  contributed the fastest FreePascal implementation, which is the one above
  (fpc.000).
- [Harald Achitz](https://www.linkedin.com/in/harald-achitz-860657139/)
  provided the C++ implementation used above (cpp.000).
- (Who is missing here?)
