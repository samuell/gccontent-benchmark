# Copyright 2017 Samuel Lampa
# samuel dot lampa at farmbio dot uu dot se
TIMECMD=/usr/bin/time -f %e

Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa.gz:
	wget ftp://ftp.ensembl.org/pub/release-67/fasta/homo_sapiens/dna/Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa.gz

%: %.gz
	gunzip $<

get_data: Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa

cpp.000.time:
	bash -c 'cd cpp.000/ && g++ -O3 -ogc gc.cpp && cd ..;'
	${TIMECMD} ./cpp.000/gc 2> .$@.tmp
	sleep 0.1
	${TIMECMD} ./cpp.000/gc 2>> .$@.tmp
	sleep 0.1
	${TIMECMD} ./cpp.000/gc 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3.0 }" > $@
	rm .$@.tmp

c.000.time:
	bash -c 'cd c.000/ && gcc -O3 -ogc gc.c && cd ..;'
	${TIMECMD} ./c.000/gc 2> .$@.tmp
	sleep 0.1
	${TIMECMD} ./c.000/gc 2>> .$@.tmp
	sleep 0.1
	${TIMECMD} ./c.000/gc 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3.0 }" > $@
	rm .$@.tmp

dlang.000.time:
	bash -c 'cd dlang.000/ && ldc2 -O5 -boundscheck=off -release gc.d && cd ..;'
	${TIMECMD} ./dlang.000/gc 2> .$@.tmp
	sleep 0.1
	${TIMECMD} ./dlang.000/gc 2>> .$@.tmp
	sleep 0.1
	${TIMECMD} ./dlang.000/gc 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3.0 }" > $@
	rm .$@.tmp

python.000.time:
	${TIMECMD} python python.000/gc.py 2> .$@.tmp
	sleep 0.1
	${TIMECMD} python python.000/gc.py 2>> .$@.tmp
	sleep 0.1
	${TIMECMD} python python.000/gc.py 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3.0 }" > $@
	rm .$@.tmp


pypy.000.time:
	${TIMECMD} pypy -OO python.000/gc.py 2> .$@.tmp
	sleep 0.1
	${TIMECMD} pypy -OO python.000/gc.py 2>> .$@.tmp
	sleep 0.1
	${TIMECMD} pypy -OO python.000/gc.py 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3.0 }" > $@
	rm .$@.tmp

cython.000.time:
	bash -c 'cd cython.000/ && cython --embed gc.pyx && gcc -I/usr/include/python2.7 -O3 -o gc gc.c -lpython2.7 && cd ..;'
	${TIMECMD} ./cython.000/gc 2> .$@.tmp
	sleep 0.1
	${TIMECMD} ./cython.000/gc 2>> .$@.tmp
	sleep 0.1
	${TIMECMD} ./cython.000/gc 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3.0 }" > $@
	rm .$@.tmp

golang.000.time:
	bash -c 'cd golang.000/ && go build gc.go && cd ..;'
	${TIMECMD} ./golang.000/gc 2> .$@.tmp
	sleep 0.1
	${TIMECMD} ./golang.000/gc 2>> .$@.tmp
	sleep 0.1
	${TIMECMD} ./golang.000/gc 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3.0 }" > $@
	rm .$@.tmp

fpc.000.time:
	bash -c 'cd fpc.000/ && fpc -Ur -O3 -Xs- -OWall -FWgc -XX -CX gc.pas && fpc -Ur -O3 -Xs- -Owall -Fwgc -XX -CX gc.pas && cd ..;' # Whole program optimization needs two compiler runs
	${TIMECMD} ./fpc.000/gc 2> .$@.tmp
	sleep 0.1
	${TIMECMD} ./fpc.000/gc 2>> .$@.tmp
	sleep 0.1
	${TIMECMD} ./fpc.000/gc 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3.0 }" > $@
	rm .$@.tmp

nim.000.time:
	bash -c 'cd nim.000/ && nim c --opt:speed --checks:off gc.nim  && cd ..;'
	${TIMECMD} ./nim.000/gc 2> .$@.tmp
	sleep 0.1
	${TIMECMD} ./nim.000/gc 2>> .$@.tmp
	sleep 0.1
	${TIMECMD} ./nim.000/gc 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3.0 }" > $@
	rm .$@.tmp

pony.000.time:
	bash -c 'cd pony.000/ && ponyc && mv pony.000 gc && cd ..;'
	${TIMECMD} ./pony.000/gc 2> .$@.tmp
	sleep 0.1
	${TIMECMD} ./pony.000/gc 2>> .$@.tmp
	sleep 0.1
	${TIMECMD} ./pony.000/gc 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3.0 }" > $@
	rm .$@.tmp

report.csv: c.000.time cpp.000.time python.000.time pypy.000.time cython.000.time golang.000.time fpc.000.time dlang.000.time nim.000.time # julia.000.time pony.000.time # <- Too slow to be included
	bash -c 'for f in *time; do echo $$f","`cat $$f`; done | sort -t, -k 2,2 | sed "s/.time//g" > $@'

all: report.csv

clean:
	rm *.time
	rm */gc
	rm report.csv
