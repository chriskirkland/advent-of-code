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

// returns path length between current node an node with target name (i.e. number of edges down the tree).  -1 means
// the target node is not a child of current node. number of nodes between is $(dist - 2)
func (n node) dist(target string) int {
	if n.name == target {
		return 0
	}

	for _, child := range n.children {
		if cDist := child.dist(target); cDist >= 0 {
			return cDist + 1
		}
	}
	return -1
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
	toVisit := make(nodes, 0, 50)

	var minOT int
	// prepopulate the list with root nodes
	for root := range roots {
		toVisit = append(toVisit, allNodes[root])
	}

	// traverse the tree (BFS) propogating the number of orbits
	for len(toVisit) > 0 {
		curr := toVisit[0]
		toVisit = toVisit[1:]

		sanDist := curr.dist("SAN")
		youDist := curr.dist("YOU")
		if curr.dist("SAN") >= 0 && curr.dist("YOU") >= 0 {
			minOT = sanDist + youDist - 2
			//fmt.Printf("recording %d orbital transfers for %s: %d to SAN and %d to YOU\n", minOT, curr.name, sanDist-1, youDist-1)
		}

		for _, child := range curr.children {
			toVisit = append(toVisit, child)
		}
	}
	fmt.Println(minOT)
}
