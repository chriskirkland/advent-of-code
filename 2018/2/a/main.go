package main

import (
	"fmt"
	"io/ioutil"
	"strings"
)

const inputFileName = "../input.txt"

func main() {
	dat, err := ioutil.ReadFile(inputFileName)
	if err != nil {
		panic("unable to read file: " + inputFileName)
	}

	var twos, threes int

	lines := strings.Split(string(dat), "\n")
	for _, line := range lines {
		line = strings.TrimSpace(line)
		two, three := classify(line)
		twos += two
		threes += three
	}

	fmt.Println(twos * threes)
}

func classify(id string) (isTwo int, isThree int) {
	freq := make(map[int32]int)
	for _, char := range id {
		freq[char]++
	}

	for _, count := range freq {
		if isTwo > 0 && isThree > 0 {
			return
		}

		switch count {
		case 2:
			isTwo = 1
		case 3:
			isThree = 1
		}
	}

	return
}
