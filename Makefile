# Copyright 2017 Samuel Lampa
# samuel dot lampa at farmbio dot uu dot se
TIMECMD=/usr/bin/time -f %e

Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa.gz:
	wget ftp://ftp.ensembl.org/pub/release-67/fasta/homo_sapiens/dna/Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa.gz

%: %.gz
	zcat $< > $@

get_data: Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa

cpp/gc:
	bash -c 'cd cpp/ && g++ -O3 -ogc gc.cpp && cd ..;'

cpp.time: cpp/gc get_data
	${TIMECMD} ./cpp/gc 2> .$@.tmp
	sleep 0.1
	${TIMECMD} ./cpp/gc 2>> .$@.tmp
	sleep 0.1
	${TIMECMD} ./cpp/gc 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3.0 }" > $@
	rm .$@.tmp

c/gc:
	bash -c 'cd c/ && gcc -O3 -ogc gc.c && cd ..;'

c.time: c/gc get_data
	${TIMECMD} ./c/gc 2> .$@.tmp
	sleep 0.1
	${TIMECMD} ./c/gc 2>> .$@.tmp
	sleep 0.1
	${TIMECMD} ./c/gc 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3.0 }" > $@
	rm .$@.tmp

d/gc:
	bash -c 'cd d/ && ldc2 -O5 -boundscheck=off -release gc.d && cd ..;'

d.time: d/gc get_data
	${TIMECMD} ./d/gc 2> .$@.tmp
	sleep 0.1
	${TIMECMD} ./d/gc 2>> .$@.tmp
	sleep 0.1
	${TIMECMD} ./d/gc 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3.0 }" > $@
	rm .$@.tmp

python.time: get_data
	${TIMECMD} python python/gc.py 2> .$@.tmp
	sleep 0.1
	${TIMECMD} python python/gc.py 2>> .$@.tmp
	sleep 0.1
	${TIMECMD} python python/gc.py 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3.0 }" > $@
	rm .$@.tmp

pypy.time: get_data
	${TIMECMD} pypy -OO python/gc.py 2> .$@.tmp
	sleep 0.1
	${TIMECMD} pypy -OO python/gc.py 2>> .$@.tmp
	sleep 0.1
	${TIMECMD} pypy -OO python/gc.py 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3.0 }" > $@
	rm .$@.tmp

cython/gc:
	bash -c 'cd cython/ && cython --embed gc.pyx && gcc -I/usr/include/python2.7 -O3 -o gc gc.c -lpython2.7 && cd ..;'

cython.time: cython/gc get_data
	${TIMECMD} ./cython/gc 2> .$@.tmp
	sleep 0.1
	${TIMECMD} ./cython/gc 2>> .$@.tmp
	sleep 0.1
	${TIMECMD} ./cython/gc 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3.0 }" > $@
	rm .$@.tmp

go/gc:
	bash -c 'cd ./go/ && go build gc.go && cd ..;'

go.time: go/gc get_data
	${TIMECMD} ./go/gc 2> .$@.tmp
	sleep 0.1
	${TIMECMD} ./go/gc 2>> .$@.tmp
	sleep 0.1
	${TIMECMD} ./go/gc 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3.0 }" > $@
	rm .$@.tmp

fpc/gc:
	bash -c 'cd fpc/ && fpc -Ur -O3 -Xs- -OWall -FWgc -XX -CX gc.pas && fpc -Ur -O3 -Xs- -Owall -Fwgc -XX -CX gc.pas && cd ..;' # Whole program optimization needs two compiler runs

fpc.time: fpc/gc get_data
	${TIMECMD} ./fpc/gc 2> .$@.tmp
	sleep 0.1
	${TIMECMD} ./fpc/gc 2>> .$@.tmp
	sleep 0.1
	${TIMECMD} ./fpc/gc 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3.0 }" > $@
	rm .$@.tmp

nim/gc:
	bash -c 'cd nim/ && nim c --opt:speed --checks:off gc.nim  && cd ..;'

nim.time: get_data
	${TIMECMD} ./nim/gc 2> .$@.tmp
	sleep 0.1
	${TIMECMD} ./nim/gc 2>> .$@.tmp
	sleep 0.1
	${TIMECMD} ./nim/gc 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3.0 }" > $@
	rm .$@.tmp

pony/gc:
	bash -c 'cd pony/ && ponyc && mv pony gc && cd ..;'

pony.time: pony/gc get_data
	${TIMECMD} ./pony/gc 2> .$@.tmp
	sleep 0.1
	${TIMECMD} ./pony/gc 2>> .$@.tmp
	sleep 0.1
	${TIMECMD} ./pony/gc 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3.0 }" > $@
	rm .$@.tmp

crystal/gc:
	bash -c 'cd crystal/ && crystal build --release gc.cr && cd ..;'

crystal.time: crystal/gc get_data
	${TIMECMD} ./crystal/gc 2> .$@.tmp
	sleep 0.1
	${TIMECMD} ./crystal/gc 2>> .$@.tmp
	sleep 0.1
	${TIMECMD} ./crystal/gc 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3.0 }" > $@
	rm .$@.tmp

report.csv: c.time \
	cpp.time \
	python.time \
	pypy.time  \
	python.time \
	go.time \
	fpc.time \
	nim.time \
	crystal.time \
	d.time
	# julia.time \
	# pony.time <- Too slow to be included
	bash -c 'for f in *time; do echo $$f"	"`cat $$f`; done | sort -k 2,2 | sed "s/.time//g" | column -t > $@'

all: report.csv

clean:
	rm *.time
	rm */gc
	rm report.csv
