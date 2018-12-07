package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"strconv"
	"strings"
)

const inputFileName = "./input.txt"

func main() {
	dat, err := ioutil.ReadFile(inputFileName)
	if err != nil {
		panic("unable to read file: " + inputFileName)
	}

	var freq int

	lines := strings.Split(string(dat), "\n")
	for _, line := range lines {
		line = strings.TrimSpace(line)
		curr, err := strconv.Atoi(line)
		if err != nil {
			fmt.Fprintf(os.Stderr, "unable to convert change '%s' to int\n", curr)
			continue
		}

		freq += curr
	}

	fmt.Println(freq)
}
