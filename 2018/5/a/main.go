package main

import (
	"fmt"
	"io/ioutil"
)

const (
	inputFileName = "../input.txt"
)

type node struct {
	val  byte
	prev *node
	next *node
}

func main() {
	dat, err := ioutil.ReadFile(inputFileName)
	if err != nil {
		panic("unable to read file: " + inputFileName)
	}
	if len(dat) == 0 {
		panic("empty input")
	}

	// construct doubly-linked list
	first := &node{
		val: dat[0],
	}
	prev := first
	for _, b := range dat[1:] {
		if b == 10 {
			// input on one line
			break
		}

		curr := &node{
			val:  b,
			prev: prev,
		}
		prev.next = curr
		prev = curr
	}

	var pass int
	var compacted bool
	for {
		for curr := first; curr.next != nil; curr = curr.next {
			if cancellable(curr, curr.next) {
				// should be compacted
				compacted = true

				if curr.prev == nil { // first
					first = curr.next.next
					first.prev = nil
				} else if curr.next.next == nil { // last
					curr.prev.next = nil
					break
				} else {
					// delete curr and curr.next
					curr.prev.next = curr.next.next
					if curr.prev.prev == nil {
						// edge case where the first.next and first.next.next get compacted, need to update first
						first = curr.prev
					}
					curr.next.next.prev = curr.prev
					// step forward - net two steps forward with the for loop
					curr = curr.next
				}

			}
		}

		if !compacted {
			// all done
			break
		}
		compacted = false
		pass++
	}

	fmt.Println(len(repr(*first)))
}

func repr(start node) string {
	curr := &start
	dat := make([]byte, 0, 1000)
	for curr != nil {
		dat = append(dat, curr.val)
		curr = curr.next
	}
	return string(dat)
}

func cancellable(a, b *node) bool {
	return abs(int(a.val)-int(b.val)) == 32
}

func abs(a int) int {
	if a >= 0 {
		return a
	}
	return -a

}
