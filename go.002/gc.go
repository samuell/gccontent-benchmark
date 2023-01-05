package main

import (
	"bufio"
        "bytes"
	"fmt"
	"log"
	"os"
)

func main() {
	// Open file
	file, err := os.Open("chry_multiplied.fa")
	if err != nil {
		log.Fatal(err)
	}

	scan := bufio.NewScanner(file)

        cgCount := 0
        acgtCount := 0
	cSlice := []byte{'C'}
	gSlice := []byte{'G'}
	nSlice := []byte{'N'}
	for scan.Scan() {
		line := scan.Bytes()
		if line[0] == '>' {
			continue
		}
		// The Count2Bytes() function in
		//   github.com/grailbio/base/simd/count_amd64.{go,s}
		// illustrates a further Go-accessible SIMD speedup of this
		// part.  (Yes, I prefer C/C++/Rust intrinsics for SIMD, but Go
		// doesn't completely lock you out.)
		cgCount += bytes.Count(line, cSlice)
		cgCount += bytes.Count(line, gSlice)

		// Minor exploit of problem statement: instead of counting As
		// and Ts, we can just count Ns and subtract from length, since
		// we are guaranteed that the line contains only {A,C,G,T,N}.
		acgtCount += len(line) - bytes.Count(line, nSlice)
	}

	gcFraction := float64(cgCount) / float64(acgtCount)
	fmt.Println(gcFraction * 100)
}
