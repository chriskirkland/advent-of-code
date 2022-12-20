package main

import (
	"bufio"
	"fmt"
	"math"
	"os"
	"strconv"
)

const key = 811589153

var inputFile string = "input.txt"

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

func (f *file) RingSize() int {
	s := 1
	for curr := f.Nodes[0].Next; curr != f.Nodes[0]; curr = curr.Next {
		s++
	}
	return s
}

func (f *file) Mix() {
	mod := f.Size() - 1
	for _, ntm := range f.Nodes {
		steps := ntm.Value

		//  generate the corresponding value in [0, f.Size()-1)
		if steps < 0 {
			quot := math.Floor(float64(steps) / float64(mod))
			steps += int(math.Abs(quot)) * mod
		} else {
			steps %= mod
		}
		if steps == 0 {
			continue // noop
		}

		// find the nodes to the left and right of the new location
		p := ntm
		for i := 0; i < steps; i++ {
			p = p.Next
		}
		n := p.Next

		// remove node from the list
		ntm.Prev.Next, ntm.Next.Prev = ntm.Next, ntm.Prev
		// insert node between p and n
		ntm.Next, ntm.Prev, p.Next, n.Prev = n, p, ntm, ntm
	}
}

func (f *file) GroveScore() int {
	// find zero
	zero := f.Nodes[0]
	for zero.Value != 0 {
		zero = zero.Next
	}

	// move "1000" steps to the right 3 times
	score := 0
	n := 1000 % f.Size()
	target := zero
	for t := 0; t < 3; t++ {
		for i := 0; i < n; i++ {
			target = target.Next
		}
		score += target.Value
	}
	return score
}

func p1(vs []int) int {
	file := NewFile(vs)
	file.Mix()
	return file.GroveScore()
}

func p2(vs []int) int {
	for ix := 0; ix < len(vs); ix++ {
		vs[ix] *= key
	}

	file := NewFile(vs)
	for i := 0; i < 10; i++ {
		file.Mix()
	}

	return file.GroveScore()
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

	fmt.Println("Part 1:", p1(vs))
	fmt.Println("Part 2:", p2(vs))
}
