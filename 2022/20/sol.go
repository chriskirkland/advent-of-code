package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
)

var inputFile string = "sample.txt"

func must(err error) {
	if err != nil {
		panic(err)
	}
}

type node struct {
	Value      int
	Next, Prev *node
}

func NewFile(vs []int) *file {
	nvs := len(vs)
	f := &file{
		Nodes: make([]*node, nvs),
	}
	f.Nodes[0] = &node{Value: vs[0]}
	for ix := 1; ix < nvs; ix++ {
		n := &node{Value: vs[ix]}
		prev := f.Nodes[ix-1]
		n.Prev, prev.Next = prev, n

		f.Nodes[ix] = n
	}
	first, last := f.Nodes[0], f.Nodes[nvs-1]
	first.Prev, last.Next = last, first

	return f
}

type file struct {
	Nodes []*node
}

func (f *file) State() []int {
	head := f.Nodes[0]
	s := []int{head.Value}
	for curr := head.Next; curr != head; curr = curr.Next {
		s = append(s, curr.Value)
	}
	return s
}
func (f *file) Size() int {
	return len(f.Nodes)
}

func (f *file) Mix() {
	for _, ntm := range f.Nodes {
		//fmt.Println("=== mixing", ntm.Value)

		v := ntm.Value
		if v < 0 {
			//  generate the corresponding value [0, f.Size())
			v -= 1
			for v < 0 {
				v += f.Size()
			}
		} else {
			// generate the corresponding value [0, f.Size())
			v %= f.Size()
		}
		if v == 0 {
			//fmt.Println("no need to move; ", ntm.Value, "is the same as 0")
			continue
		}
		//fmt.Println("changed", ntm.Value, "to", v, "moves to the right")

		// swap right 'v' places
		p := ntm
		for i := 0; i < v; i++ {
			p = p.Next
		}
		n := p.Next
		//fmt.Println("moving", ntm.Value, "between", p.Value, "and", n.Value)

		// remove node from the list
		ntm.Prev.Next, ntm.Next.Prev = ntm.Next, ntm.Prev
		// insert node between p and n
		ntm.Next, ntm.Prev, p.Next, n.Prev = n, p, ntm, ntm

		//fmt.Println(f.State())
		//fmt.Println()
	}
}

func (f *file) AfterZero(n int) int {
	// find zero
	zero := f.Nodes[0]
	for zero.Value != 0 {
		zero = zero.Next
	}

	// move n places to the right
	n %= len(f.Nodes)
	target := zero
	for i := 0; i < n; i++ {
		target = target.Next
	}
	return target.Value
}

func main() {
	// read input
	input, err := os.Open(inputFile)
	must(err)
	defer input.Close()

	var vs []int
	scanner := bufio.NewScanner(input)
	for scanner.Scan() {
		v, err := strconv.Atoi(scanner.Text())
		must(err)
		vs = append(vs, v)
	}
	must(scanner.Err())

	file := NewFile(vs)
	//fmt.Println(file.State())
	//fmt.Println()

	file.Mix()

	fmt.Println(file.AfterZero(1000))
	fmt.Println(file.AfterZero(2000))
	fmt.Println(file.AfterZero(3000))
}
