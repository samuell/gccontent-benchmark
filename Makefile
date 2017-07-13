# Copyright 2016 Samuel Lampa
# samuel dot lampa at rilpartner dot com
#
TIMECMD=/usr/bin/time -f %e

Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa.gz:
	wget ftp://ftp.ensembl.org/pub/release-67/fasta/homo_sapiens/dna/Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa.gz

%: %.gz
	gunzip $<

get_data: Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa

test_python:
	${TIMECMD} python python_v100/gc.py 2> python_time.log
	sleep 1
	${TIMECMD} python python_v100/gc.py 2>> python_time.log
	sleep 1
	${TIMECMD} python python_v100/gc.py 2>> python_time.log
	sleep 1
	cat python_time.log | awk "{ SUM += $1 } END { print SUM/3 }"
