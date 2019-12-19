package main

import (
	"fmt"
	"io/ioutil"
	"strings"
)

const (
	inputFileName = "input.txt"
)

type node struct {
	name     string
	weight   uint
	children nodes
}

type nodes []*node

func (ns nodes) String() string {
	names := make([]string, 0, len(ns))
	for _, elem := range ns {
		names = append(names, elem.name)
	}
	return strings.Join(names, " ")
}


func main() {
	allNodes := make(map[string]*node)
	roots := make(map[string]bool)

	dat, err := ioutil.ReadFile(inputFileName)
	if err != nil {
		panic(err)
	}

	for _, line := range strings.Split(string(dat), "\n") {
		fields := strings.Split(line, ")")
		a, b := fields[0], fields[1]  // b orbits a
		//fmt.Printf("read '%s' -> '%s'\n", a, b)

		// b is not a root of the tree
		delete(roots, b)

		// get a node
		aNode, ok := allNodes[a]
		if !ok {
			aNode = &node{
				name: a,
			}
			allNodes[a] = aNode
			roots[a] = true
		}

		// get b node
		bNode, ok := allNodes[b]
		if !ok {
			bNode = &node{
				name: b,
			}
			allNodes[b] = bNode
		}

		// add orbit
		aNode.children = append(aNode.children, bNode)

		//fmt.Printf("roots: %s\n\n", strings.Join(keys(roots), " "))
	}

	// count the number of orbits
	var orbits uint
	toVisit := make(nodes, 0, 50)

	// prepopulate the list with root nodes
	for root := range roots {
		toVisit = append(toVisit, allNodes[root])
	}

	// traverse the tree (BFS) propogating the number of orbits
	for len(toVisit) > 0 {
		curr := toVisit[0]
		toVisit = toVisit[1:]

		//fmt.Printf("visiting %s with %d orbits and children: %s\n", curr.name, curr.weight, curr.children)

		orbits += curr.weight
		if len(curr.children) == 0 {
			continue
		}

		for _, child := range curr.children {
			//fmt.Printf("adding child %s to queue\n", child.name)
			child.weight = curr.weight + 1
			toVisit = append(toVisit, child)
		}
		//fmt.Printf("left to visit: %s\n\n", toVisit)
	}
	fmt.Println(orbits)
}

func keys(m map[string]bool) []string {
	ks := make([]string, 0, len(m))
	for k := range m {
		ks = append(ks, k)
	}
	return ks
}
