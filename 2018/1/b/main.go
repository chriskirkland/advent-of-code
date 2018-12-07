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
	visited := make(map[int]bool)

	lines := strings.Split(string(dat), "\n")
	for {
		// "Note that your device might need to repeat its list of frequency changes many times before a duplicate frequency is found...."
		for _, line := range lines {
			line = strings.TrimSpace(line)
			curr, err := strconv.Atoi(line)
			if err != nil {
				fmt.Fprintf(os.Stderr, "unable to convert change '%s' to int\n", curr)
				continue
			}

			if _, ok := visited[freq]; ok {
				fmt.Println(freq)
				os.Exit(0)
			}

			visited[freq] = true
			freq += curr
		}
	}
}
