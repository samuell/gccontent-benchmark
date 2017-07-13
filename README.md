# Comparing string processing performance of programming languages

... using a simple bioinformatics task: Computing the GC fraction of DNA.

## Usage

```
make all
cat report.csv
```

## More info

This is a continuation of a previous benchmarking project, covered in [this blog post](http://saml.rilspace.com/moar-languagez-gc-content-in-python-d-fpc-c-and-c).

# Acknowledgements

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
