package main

import (
	"fmt"
	"os"
	"strconv"
)

const (
	inputFileName = "../input.txt"
)

type password struct {
	val string
	seed uint8
}

func (p password) prepend(digit uint8) password {
	n := p
	n.val = fmt.Sprintf("%d%s", digit, n.val)
	return n
}

func (p password) append(digit uint8) password {
	n := p
	n.val = fmt.Sprintf("%s%d", n.val, digit)
	return n
}

func (p password) String() string {
	return p.val
}

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
	queue := make([]password, 0, 1000)
	visited := make(map[password]bool, 50000)

	// add duplicates to the queue
	for i := uint8(1); i <= 9; i++ {
		queue = append(queue, password{
			val: fmt.Sprintf("%d%d", i, i),
			seed: i,
		})
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

		elemS := elem.String()
		if len(elemS) == 6 {
			if elemS >= minS && elemS <= maxS {
				passwords[elemS] = true
			}
			//fmt.Printf("*** checking %s <= %s <= %s (%t)\n", minS, elem, maxS, passwords[elemS])
			continue
		}

		first := elemS[0] - '0'
		if first == elem.seed {
			first--	// no more than 2 repeats for seed pair
		}
		last := elemS[len(elemS)-1] - '0'
		if last == elem.seed {
			last++	// no more than 2 repeats for seed pair
		}

		// prepend all possible digits
		for digit := uint8(1); digit <= first; digit++ {
			//fmt.Printf("enqueueing with %d prepended (le %d)\n", digit, first)
			queue = append(queue, elem.prepend(digit))
		}

		// append all possible digits
		for digit := last; digit <= 9; digit++ {
			//fmt.Printf("enqueueing with %d appended (ge %d)\n", digit, last)
			queue = append(queue, elem.append(digit))
		}
	}

	fmt.Println(len(passwords))
}
