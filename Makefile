# Copyright 2016 Samuel Lampa
# samuel dot lampa at rilpartner dot com
#
TIMECMD=/usr/bin/time -f %e

Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa.gz:
	wget ftp://ftp.ensembl.org/pub/release-67/fasta/homo_sapiens/dna/Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa.gz

%: %.gz
	gunzip $<

get_data: Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa

python.000.time:
	${TIMECMD} python python.000/gc.py 2> .$@.tmp
	${TIMECMD} python python.000/gc.py 2>> .$@.tmp
	${TIMECMD} python python.000/gc.py 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3 }" > $@
	rm .$@.tmp


pypy.000.time:
	${TIMECMD} pypy python.000/gc.py 2> .$@.tmp
	${TIMECMD} pypy python.000/gc.py 2>> .$@.tmp
	${TIMECMD} pypy python.000/gc.py 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3 }" > $@
	rm .$@.tmp

cython.000.time:
	bash -c 'cd cython.000/ && cython --embed gc.pyx && gcc -I/usr/include/python2.7 -O3 -o gc gc.c -lpython2.7 && cd ..;'
	${TIMECMD} ./cython.000/gc 2> .$@.tmp
	${TIMECMD} ./cython.000/gc 2>> .$@.tmp
	${TIMECMD} ./cython.000/gc 2>> .$@.tmp
	cat .$@.tmp | awk "{ SUM += \$$1 } END { print SUM/3 }" > $@
	rm .$@.tmp

time_python: python.000.time

print_report:
	bash -c 'for f in *time; do echo $$f; cat $$f; echo; done'
