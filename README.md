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

## Current results

**WARNING: Current results (as of Feb 20, 2021) outdated. Udpated results coming later today**

These are some results (Execution times in seconds, smaller is better) from
running some of the tests in the Makefile, on a Dell Inspiron laptop with an
Intel(R) Core(TM) i7-8650U CPU @ 1.90GHz, with Xubuntu 18.04 Bionic LTS 64bit
as operating system:

| Language                                                                                                      | Execution time (s) | Compiler versions                                                         |
|---------------------------------------------------------------------------------------------------------------|-------------------:|---------------------------------------------------------------------------|
| [Rust.002.bitshift](rust.002.bitshift/src/main.rs)<br>Contributed by [@sstadick](https://github.com/sstadick) |              0.436 | Rust 1.52.0-nightly (152f66092 2021-02-17)                                |
| [Rust.001](rust.001/src/main.rs)<br>Contributed by [@sstadick](https://github.com/sstadick)                   |              0.514 | Rust 1.52.0-nightly (152f66092 2021-02-17)                                |
| [C.001](c.001/gc.c)<br>Contributed by [@jmarshall](https://github.com/jmarshall)                              |              0.515 | gcc (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0                                   |
| [C++.001](cpp.001/gc.cpp)<br>Contributed by [@jmarshall](https://github.com/jmarshall)                        |              0.537 | g++ (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0                                   |
| [C](c/gc.c)                                                                                                   |              0.614 | gcc (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0                                   |
| [D](d/gc.d)                                                                                                   |              0.660 | The LLVM D compiler (1.22.0) (LLVM 10.0.0)                                |
| [Go.001.unroll](go.001.unroll/gc.go)<br>Contributed by [@egonelbre](https://github.com/egonelbre)             |              0.831 | Go 1.15 linux/amd64                                                       |
| [Rust](rust/src/main.rs)<br>With improvements contributed by [@rob-p](https://github.com/rob-p)               |              0.873 | Rust 1.52.0-nightly (152f66092 2021-02-17)                                |
| [Go](go/gc.go)                                                                                                |              0.970 | Go 1.15 linux/amd64                                                       |
| [C++](cpp/gc.cpp)                                                                                             |              1.401 | g++ (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0                                   |
| [PyPy](pypy/gc.py)                                                                                            |              1.886 | PyPy 5.10.0 with GCC 7.3.0 (Python 2.7.13)                                |
| [Crystal](crystal/gc.cr)                                                                                      |              2.201 | Crystal 0.35.1 [5999ae29b] (2020-06-19) LLVM: 8.0.0                       |
| [Nim](nim/gc.nim)                                                                                             |              2.230 | Nim Compiler Version 0.17.2 (2018-02-05)                                  |
| [FPC](gc.pas)                                                                                                 |              3.230 | Free Pascal Compiler version 3.0.4+dfsg-18ubuntu2 [2018/08/29] for x86_64 |
| [Crystal-CSP](crystal-csp/gc.cr)                                                                              |              3.837 | Crystal 0.35.1 [5999ae29b] (2020-06-19) LLVM: 8.0.0                       |
| [Cython](cython/gc.pyx)                                                                         |              5.417 | Cython version 0.26.1
| [Python](python/gc.py)                                                                          |              7.150 | Python 3.7.0                                                              |

## Results with relaxed constraints on reading line-by-line

The below contributed versions departs slightly from reading line-by-line (by
some definition of that requirement, which is clearly very hard to define):

| Language                                                                                       | Execution time (s) | Compiler versions                       |
|------------------------------------------------------------------------------------------------|-------------------:|-----------------------------------------|
| [C.002.rawio](c.002.rawio/gc.c)<br>Contributed by [@jmarshall](https://github.com/jmarshall)   |              0.040 | gcc (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0 |

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
