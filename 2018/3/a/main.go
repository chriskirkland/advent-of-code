package main

import (
	"fmt"
	"io/ioutil"
	"regexp"
	"strconv"
	"strings"
)

const (
	inputFileName = "./input.txt"
	size = 2000
)

var claimRe = regexp.MustCompile(`#(\d+) @ (\d+),(\d+): (\d+)x(\d+)`)

var conflicts int

func main() {
	dat, err := ioutil.ReadFile(inputFileName)
	if err != nil {
		panic("unable to read file: " + inputFileName)
	}

	// each (x,y) represents the unit square with ULH (x,y) and LRH (x+1,y+1)
	var fabric [size][size]int

	lines := strings.Split(string(dat), "\n")
	for _, line := range lines {
		line = strings.TrimSpace(line)

		// parse each line into single elf's claim
		c := newClaim(line)

		// mark each claim on the fabric
		c.mark(&fabric)
	}

	fmt.Println(conflicts)
}

type claim struct {
	x, y, width, height, id int
}

func (c claim) mark(f *[size][size]int) {
	for xoff := 0; xoff < c.width; xoff++ {
		for yoff := 0; yoff < c.height; yoff++ {
			f[c.x+xoff][c.y+yoff]++

			// count the claim conflicts while we're marking them to avoid an additional scan (n^2)
			if f[c.x+xoff][c.y+yoff] == 2 {
				conflicts++
			}
		}
	}
}

func newClaim(line string) claim {
	matches := claimRe.FindStringSubmatch(line)
	if len(matches) != 6 {
		panic(fmt.Errorf("invalid number of matches for line '%s': %d. Expected 6", line, len(matches)))
	}

	return claim {
		x: mustConvert(matches[2]),
		y: mustConvert(matches[3]),
		width: mustConvert(matches[4]),
		height: mustConvert(matches[5]),
	}
}

func mustConvert(s string) int {
	v, err := strconv.Atoi(s)
	if err != nil {
		panic("failed conversion of string to int: "+s)
	}

	return v
}
