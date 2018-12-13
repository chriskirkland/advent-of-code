package main

import (
	"fmt"
	"io"
	"os"
	"sort"
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

	requirements := make(map[string]map[string]bool)

	var pre, post string
	for {
		_, err = fmt.Fscanf(f, "Step %s must be finished before step %s can begin.\n", &pre, &post)
		if err != nil {
			if err == io.EOF || err == io.ErrUnexpectedEOF{
				break
			}
			panic(err)
		}

		// add new nodes if necessary
		if _, ok := requirements[pre]; !ok {
			requirements[pre] = make(map[string]bool)
		}
		if _, ok := requirements[post]; !ok {
			requirements[post] = make(map[string]bool)
		}

		// propogate dependency to dependants of our current target
		propogate(requirements, pre, post)
	}

	// print "walk" order
	for len(requirements) > 0 {
		minDeps := 10000
		var mins []string

		for step, deps := range requirements{
			if len(deps) < minDeps	 {
				minDeps = len(deps)
				mins = []string{step}
			}  else if  len(deps) == minDeps {
				mins = append(mins, step)
			}
		}

		if len(mins) == 0 {
			panic(fmt.Errorf("too many mins (%d): %+v\n", len(mins), mins))
		}

		if len(mins) > 1 {
			sort.Strings(mins)
		}
		winner := mins[0]

		fmt.Print(winner)

		// delete winner from all deps
		for step, deps := range requirements{
			if deps[winner] {
				delete(deps, winner)
			}
			requirements[step] = deps
		}
		delete(requirements, winner)
	}

	fmt.Println()
}

func propogate(m map[string]map[string]bool, prereq, start string) {
	markQueue := []string{prereq}
	marked := make(map[string]bool)

	for len(markQueue) > 0 {
		// pop an element
		elem := markQueue[0]
		markQueue = markQueue[1:]

		// add secondary dependant
		for dependant := range m[elem] {
			if !marked[dependant]{
				markQueue = append(markQueue, dependant)
			}
		}

		// mark prereq
		marked[elem] = true
		m[start][elem] = true
	}
}

func print(m map[string]map[string]bool) {
	for step, prereqs := range m {
		fmt.Printf("Step %s has prereqs: ", step)
		for prereq := range prereqs {
			fmt.Print(prereq, ", ")
		}
		fmt.Println()
	}
}