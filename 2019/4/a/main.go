package main

import (
	"fmt"
	"os"
	"strconv"
)

const (
	inputFileName = "../input.txt"
)

type password string

func main() {
	f, err := os.Open(inputFileName)
	if err != nil {
		panic(err)
	}
	defer f.Close()

	var min, max int
	_, err = fmt.Fscanf(f, "%d-%d", &min, &max)
	if err != nil {
		panic(err)
	}
	minS, maxS := strconv.Itoa(min), strconv.Itoa(max)

	passwords := make(map[string]bool, 1000)
	queue := make([]string, 0, 1000)
	visited := make(map[string]bool, 50000)

	//TODO(cmkirkla): prune visited nodes

	// add duplicates to the queue
	for i := 1; i <= 9; i++ {
		queue = append(queue, fmt.Sprintf("%d%d", i, i))
	}

	for len(queue) > 0 {
		// pop
		elem := queue[0]
		queue = queue[1:]

		if visited[elem] {
			continue
		}
		visited[elem] = true

		//fmt.Printf("processing '%s' (queue size %d)\n", elem, len(queue))

		if len(elem) == 6 {
			if elem >= minS && elem <= maxS {
				passwords[elem] = true
			}
			//fmt.Printf("*** checking %s <= %s <= %s (%t)\n", minS, elem, maxS, passwords[elem])
			continue
		}
		first := elem[0] - '0'
		last := elem[len(elem)-1] - '0'

		// prepend all possible digits
		for digit := uint8(1); digit <= first; digit++ {
			//fmt.Printf("enqueueing with %d prepended (le %d)\n", digit, first)
			queue = append(queue, fmt.Sprintf("%d%s", digit, elem))
		}

		// append all possible digits
		for digit := last; digit <= 9; digit++ {
			//fmt.Printf("enqueueing with %d appended (ge %d)\n", digit, last)
			queue = append(queue, fmt.Sprintf("%s%d", elem, digit))
		}
	}

	fmt.Println(len(passwords))
}
