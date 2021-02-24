# Copyright 2017 Samuel Lampa
# samuel dot lampa at farmbio dot uu dot se

# ------------------------------------------------
# Configuration options
# ------------------------------------------------

TESTFILE_MULTIPLICATION_FACTOR=10
TEST_REPETITIONS=10
SLEEPTIME_SECONDS=1

CRYSTAL_WORKERS=2

# ------------------------------------------------
# Main rules
# ------------------------------------------------

.DEFAULT_GOAL := all

all: report.md

html-report: report.html

clean:
	rm -rf *.time \
		*.version \
		*/gc.bin \
		*/gc \
		*/gc.o \
		cython/gc.c \
		java/gc.class \
		nim/nimcache \
		rust*/target \
		report.*

# ------------------------------------------------
# Time program execution
# ------------------------------------------------

# Set up time command
TIMECMD=/usr/bin/time -f %e # Use a different time command on MacOS
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
	TIMECMD=gtime -f %e
endif

# Do the timing of program runs
%.time: %/gc.bin chry_multiplied.fa
	rm -f $@.tmp
	for i in $(shell seq ${TEST_REPETITIONS}); do \
		echo "Test #$$i ..."; \
		${TIMECMD} $< 2>> $@.tmp; \
		sleep ${SLEEPTIME_SECONDS}; \
	done
	cat $@.tmp | awk "{ SUM += \$$1; LC += 1 } END { print SUM/LC }" > $@
	rm $@.tmp

# ------------------------------------------------
# Create the final report
# ------------------------------------------------

report.html: report.md
	pandoc -i $< -o $@

report.md: c.time c.version \
	c.001.time c.version \
	c.003.ril.time c.version \
	cpp.time cpp.version \
	cpp.001.time cpp.version \
	crystal.time crystal.version \
	crystal.001.csp.time crystal.version \
	crystal.002.peek.time crystal.version \
	cython.time cython.version \
	d.time d.version \
	fpc.time fpc.version \
	go.time go.version \
	go.001.unroll.time go.version \
	java.time java.version \
	graalvm.time graalvm.version \
	nim.time nim.version \
	nim.001.time nim.version \
	nim.002.time nim.version \
	node.time node.version \
	perl.time perl.version \
	pypy.time pypy.version \
	python.time python.version \
	rust.time rust.version \
	rust.001.time rust.version \
	rust.002.bitshift.time rust.version \
	rust.003.vectorized.time rust.version \
	rust.004.simd.time rust.version \
	julia.time julia.version
	#pony.time pony.version
	echo "| Language | Time (s) | Compiler or interpreter version |" > $@
	echo "|----------|----------|---------------------------------|" >> $@
	bash -c 'for f in *.time; do f2=$${f%.time}; echo "| [$$f2]($$f2) | $$(cat $$f) | $$(cat $$(echo $$f2 | grep -oP "^[a-z0-9]+").version) |"; done | sort -t"|" -k 3,3f >> $@'

# ------------------------------------------------
# Write version information for each language
# ------------------------------------------------
c.version:
	gcc --version | head -n 1 > $@
cpp.version:
	g++ --version | head -n 1 > $@
crystal.version:
	crystal version | tr "\n" " " | cut -d" " -f 1-7 > $@
cython.version:
	cython --version 2> $@
d.version:
	ldc2 --version | head -n 2 | tr "\n" " " | cut -d" " -f 1-7,10-13 > $@
fpc.version:
	fpc -version |& head -n 1 | cut -d" " -f 2-9 > $@
go.version:
	go version > $@
graalvm.version:
	native-image --version > $@
nim.version:
	nim --version |& head -n 1 > $@
node.version:
	node --version > $@
perl.version:
	perl --version | head -n 2 | tail -n 1 > $@
pony.version:
	ponyc --version > $@
pypy.version:
	pypy --version |& tr "\n" " " > $@
python.version:
	python --version > $@
rust.version:
	rustc --version > $@
julia.version:
	julia --version > $@
java.version:
	java -version 2>&1 | head -n 2 | tr "\n" " " > $@

# ------------------------------------------------
# Get Data
# ------------------------------------------------

# Download data
Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa.gz:
	wget ftp://ftp.ensembl.org/pub/release-67/fasta/homo_sapiens/dna/Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa.gz

# Un-Gzip
%: %.gz
	zcat < $< > $@

# Multiply the length of the example data file
# by the TESTFILE_MULTIPLICATION_FACTOR setting.
chry_multiplied.fa: Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa
	rm -f $@;
	for i in $(shell seq 1 ${TESTFILE_MULTIPLICATION_FACTOR}); do \
		cat $< >> $@; \
	done;

# ------------------------------------------------
# Compile
# ------------------------------------------------

# C
%.bin: %.c
	gcc -O3 -o $@ $<

# C++
%.bin: %.cpp
	g++ -O3 -o $@ $<

# Crystal
%.bin: %.cr
	crystal build --release -o $@ $<

# Crystal with threading and CSP-style concurrency
crystal.001.csp/gc: crystal.001.gc/gc.cr
	crystal build --release -Dpreview_mt -o $@ $<

# Cython
cython/gc.bin: cython/gc.pyx
	cython --embed $< \
		&& gcc -I/usr/include/python2.7 -O3 -o $@ cython/gc.c -lpython2.7

# D
%.bin: %.d
	ldc2 -O5 -boundscheck=off -release -of=$@ $<

# FreePascal
%.bin: %.pas
	# NOTE: Whole program optimization needs two compiler runs
	fpc -Ur -O3 -Xs- -OWall -FWgc -XX -CX -o$@ $< \
		&& fpc -Ur -O3 -Xs- -Owall -Fwgc -XX -CX -o$@ $<

# Go
%.bin: %.go
	go build -o $@ $<

# GraalVM
graalvm/gc.bin: graalvm/gc.java
	bash -c 'cd graalvm && javac gc.java && native-image -O5 gc && cd ..';
	cp graalvm/gc $@;

# Java
java/gc.class: java/gc.java
	javac $<;
java/gc.bin: java/gc.class
	cp java/gc.sh $@;

# Julia
# We need to copy the Julia script to the canonical path to simplify the e.g.
# the cleaning rule
julia/gc.bin: julia/gc.jl
	cp $< $@

# Nim
%.bin: %.nim
	nim c -d:danger $< \
		&& mv $(basename $@) $@

# Node
# We need to copy the node script to the canonical path to simplify the e.g.
# the cleaning rule
node/gc.bin: node/gc.js
	cp $< $@

# Perl
# We need to copy the perl script to the canonical path to simplify the e.g.
# the cleaning rule
perl/gc.bin: perl/gc.pl
	cp $< $@

# Python
# We need to copy the python script to the canonical path to simplify the e.g.
# the cleaning rule
python/gc.bin: python/gc.py
	cp $< $@

# Pypy
# We need to copy the pypy script to the canonical path to simplify the e.g.
# the cleaning rule
pypy/gc.bin: pypy/gc.py
	cp $< $@

# Rust
rust/gc.bin: rust/src/main.rs rust/Cargo.toml
	RUSTFLAGS="-C target-cpu=native" cargo +nightly build --release --manifest-path $(word 2,$^) -Z unstable-options --out-dir $(shell dirname $@) \
		&& mv $(basename $@) $@

rust%/gc.bin: rust%/src/main.rs rust%/Cargo.toml
	RUSTFLAGS="-C target-cpu=native" cargo +nightly build --release --manifest-path $(word 2,$^) -Z unstable-options --out-dir $(shell dirname $@) \
		&& mv $(basename $@) $@

#TODO: Update
#pony/gc: pony/gc.pony
#	ponyc
