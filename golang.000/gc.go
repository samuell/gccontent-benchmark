package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
)

func main() {
	var at, gc, other int
	counters := [256]*int{
		'A': &at,
		'T': &at,
		'G': &gc,
		'C': &gc,
	}
	for i, counter := range counters {
		if counter == nil {
			counters[i] = &other
		}
	}
	file, err := os.Open("Homo_sapiens.GRCh37.67.dna_rm.chromosome.Y.fa")
	if err != nil {
		log.Fatal(err)
	}
	scan := bufio.NewScanner(file)
	for scan.Scan() {
		line := scan.Bytes()
		if len(line) == 0 || line[0] == '>' {
			continue
		}
		for _, c := range line {
			(*counters[c])++
		}
	}
	gcFraction := float32(gc) / float32(at+gc)
	fmt.Println(gcFraction * 100)
}
