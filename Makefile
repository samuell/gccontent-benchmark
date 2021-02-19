# Copyright 2017 Samuel Lampa
# samuel dot lampa at farmbio dot uu dot se
TIMECMD=/usr/bin/time -f %e
REPETITIONS=10
TESTFILE_MULTIPLICATION_FACTOR=10
SLEEPTIME=0.5

Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa.gz:
	wget ftp://ftp.ensembl.org/pub/release-67/fasta/homo_sapiens/dna/Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa.gz

%: %.gz
	zcat $< > $@

chry_multiplied.fa: Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa
	rm -f $@;
	for i in $(shell seq 1 ${TESTFILE_MULTIPLICATION_FACTOR}); do \
		cat $< >> $@; \
	done;

cpp/gc:
	bash -c 'cd cpp/ && g++ -O3 -ogc gc.cpp && cd ..;'

cpp.001/gc: cpp.001/gc.cpp
	g++ -O3 -Wall -o $@ cpp.001/gc.cpp

c/gc:
	bash -c 'cd c/ && gcc -O3 -ogc gc.c && cd ..;'

c.001/gc: c.001/gc.c
	gcc -O3 -Wall -o $@ c.001/gc.c

c.002.rawio/gc: c.002.rawio/gc.c
	gcc -O3 -Wall -o $@ c.002.rawio/gc.c

d/gc:
	bash -c 'cd d/ && ldc2 -O5 -boundscheck=off -release gc.d && cd ..;'

cython/gc:
	bash -c 'cd cython/ && cython --embed gc.pyx && gcc -I/usr/include/python2.7 -O3 -o gc gc.c -lpython2.7 && cd ..;'

rust/gc: rust/src/main.rs
	bash -c 'cd ./rust/ && cargo build --release && cp target/release/gc . && cd ..;'

rust.001/gc: rust.001/src/main.rs
	bash -c 'cd ./rust.001/ && cargo build --release && cp target/release/gc . && cd ..;'

go/gc:
	bash -c 'cd ./go/ && go build gc.go && cd ..;'

go.001.unroll/gc:
	bash -c 'cd ./go.001.unroll/ && go build gc.go && cd ..;'

fpc/gc:
	bash -c 'cd fpc/ && fpc -Ur -O3 -Xs- -OWall -FWgc -XX -CX gc.pas && fpc -Ur -O3 -Xs- -Owall -Fwgc -XX -CX gc.pas && cd ..;' # Whole program optimization needs two compiler runs

nim/gc:
	bash -c 'cd nim/ && nim c --opt:speed --checks:off gc.nim  && cd ..;'

pony/gc:
	bash -c 'cd pony/ && ponyc && mv pony gc && cd ..;'

crystal/gc:
	bash -c 'cd crystal/ && crystal build --release gc.cr && cd ..;'

crystal.001.csp/gc:
	bash -c 'cd crystal.001.csp/ && crystal build --release -Dpreview_mt -o gc gc.cr && cd ..;'

%.time: %/gc chry_multiplied.fa
	rm -f .$@.tmp
	for i in $(shell seq ${REPETITIONS}); do \
		echo "Test #$$i ..."; \
		${TIMECMD} $< 2>> .$@.tmp; \
		sleep ${SLEEPTIME}; \
	done
	cat .$@.tmp | awk "{ SUM += \$$1; LC += 1 } END { print SUM/LC }" > $@
	rm .$@.tmp

report.csv: c.time \
	c.001.time \
	cpp.time \
	cpp.001.time \
	crystal.time \
	crystal-csp.time \
	cython.time \
	d.time \
	fpc.time \
	go.time \
	go.001.unroll.time \
	nim.time \
	python.time \
	pypy.time  \
	python.time \
	rust.time \
	rust.001.time
	# julia.time \
	# pony.time <- Too slow to be included
	bash -c 'for f in *time; do echo $$f"	"`cat $$f`; done | sort -k 2,2 | sed "s/.time//g" | column -t > $@'

all: report.csv

clean:
	rm *.time
	rm */gc
	rm report.csv
