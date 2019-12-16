package main

import (
	"fmt"
	"io"
	"os"
)

const (
	inputFileName = "../input.txt"
)

func main() {
	f, err := os.Open(inputFileName)
	if err != nil {
		panic(err)
	}
	defer f.Close()

	var mass, fuel int
	for {
		_, err = fmt.Fscanf(f, "%d", &mass)
		if err != nil {
			if err == io.EOF || err == io.ErrUnexpectedEOF {
				break
			}
			panic(err)
		}

		fuel += mass/3 - 2
	}

	fmt.Println(fuel)
}
