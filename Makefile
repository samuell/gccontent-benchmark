# Copyright 2017 Samuel Lampa
# samuel dot lampa at farmbio dot uu dot se

# ------------------------------------------------
# Configuration options
# ------------------------------------------------

TESTFILE_MULTIPLICATION_FACTOR=10
TEST_REPETITIONS=10
SLEEPTIME_SECONDS=0.5

# ------------------------------------------------
# Main rules
# ------------------------------------------------

all: report.csv

clean:
	rm -rf *.time \
		*/gc.bin \
		*/gc \
		*/gc.o \
		nim/nimcache \
		rust*/target \
		report.csv

# ------------------------------------------------
# Time program execution
# ------------------------------------------------

# Set up time command
TIMECMD=/usr/bin/time -f %e # Use a different time command on MacOS
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
	TIMECMD=gtime -f %e
endif

#  Do the timing of program runs
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

report.csv: c.time \
	c.001.time \
	cpp.time \
	cpp.001.time \
	crystal.time \
	crystal.001.csp.time \
	cython.time \
	d.time \
	fpc.time \
	go.time \
	go.001.unroll.time \
	nim.time \
	pypy.time \
	python.time \
	rust.time \
	rust.001.time \
	rust.002.bitshift.time \
	julia.time
	# pony.time <- Too slow to be included
	bash -c 'for f in $^; do f2=$${f%.time}; echo $$f2,$$(cat $$f); done | sort -t, -k 2,2 > $@'

# ------------------------------------------------
# Get Data
# ------------------------------------------------

# Download data
Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa.gz:
	wget ftp://ftp.ensembl.org/pub/release-67/fasta/homo_sapiens/dna/Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa.gz

# Un-Gzip
%: %.gz
	zcat $< > $@

# Multiply the length of the example data file
# by the TESTFILE_MULTIPLICATION_FACTOR setting.
chry_multiplied.fa: Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa Makefile
	rm -f $@;
	for i in $(shell seq 1 ${TESTFILE_MULTIPLICATION_FACTOR}); do \
		cat $< >> $@; \
	done;

# ------------------------------------------------
# Compile
# ------------------------------------------------

# C++
%.bin: %.cpp
	g++ -O3 -o $@ $<

# C
%.bin: %.c
	gcc -O3 -Wall -o $@ $<

# Crystal
%.bin: %.cr
	crystal build --release -o $@ $<

# Crystal with threading and CSP-style concurrency
crystal.001.csp/gc: crystal.001.gc/gc.cr
	crystal build --release -Dpreview_mt -o $@ $<

# Cython
cython/gc.bin: cython/gc.pyx cython/gc.c
	cython --embed $< \
		&& gcc -I/usr/include/python2.7 -O3 -o $@ $(word 2,$^) -lpython2.7

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

# Julia
# We need to copy the Julia script to the canonical path to simplify the e.g.
# the cleaning rule
julia/gc.bin: julia/gc.jl
	cp $< $@

# Nim
%.bin: %.nim
	nim c --opt:speed --checks:off $< \
		&& mv $(basename $@) $@

# Python
# We need to copy the python script to the canonical path to simplify the e.g.
# the cleaning rule
python/gc.bin: python/gc.py
	cp $< $@

# Pypy
# ... and the same goes for pypy:
pypy/gc.bin: pypy/gc.py
	cp $< $@

# Rust
rust/gc.bin: rust/src/main.rs rust/Cargo.toml
	cargo build --release --manifest-path $(word 2,$^) -Z unstable-options --out-dir $(shell dirname $@) \
		&& mv $(basename $@) $@

rust%/gc.bin: rust%/src/main.rs rust%/Cargo.toml
	cargo build --release --manifest-path $(word 2,$^) -Z unstable-options --out-dir $(shell dirname $@) \
		&& mv $(basename $@) $@

#TODO: Update
#pony/gc: pony/gc.pony
#	ponyc
