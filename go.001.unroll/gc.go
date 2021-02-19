package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
)

func main() {
	counters := [8][256]int64{}

	// Open file
	file, err := os.Open("chry_multiplied.fa")
	if err != nil {
		log.Fatal(err)
	}

	scan := bufio.NewScanner(file)

	for scan.Scan() {
		line := scan.Bytes()
		if line[0] == '>' {
			continue
		}
		for len(line) >= 8 {
			counters[0][line[0]]++
			counters[1][line[1]]++
			counters[2][line[2]]++
			counters[3][line[3]]++
			counters[4][line[4]]++
			counters[5][line[5]]++
			counters[6][line[6]]++
			counters[7][line[7]]++
			line = line[8:]
		}
		for _, c := range line {
			counters[0][c]++
		}
	}

	total := [256]int64{}
	for i := range counters {
		for k, v := range counters[i] {
			total[k] += v
		}
	}

	gc := total['G'] + total['C']
	at := total['A'] + total['T']
	gcFraction := float32(gc) / float32(at+gc)
	fmt.Println(gcFraction * 100)
}
