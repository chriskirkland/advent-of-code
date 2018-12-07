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

	// sentinel for a fabric square which was claimed two or more times
	conflict = -1
)

var claimRe = regexp.MustCompile(`#(\d+) @ (\d+),(\d+): (\d+)x(\d+)`)

var uniqs map[int]claim

func main() {
	// initialize uniqs map
	uniqs = make(map[int]claim)

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
		c.mark(&fabric, false)
	}

	if num := len(uniqs); num != 1  {
		panic(fmt.Errorf("unexpected number of unconflicted claims: %d", num))
	}

	for id := range uniqs {
		fmt.Println(id)
	}
}

type claim struct {
	x, y, width, height, id int
}

func (c claim) mark(f *[size][size]int, conflicted bool) {
	// mark current claim as unique. it will be removed later if it isn't unique.
	if !conflicted {
		uniqs[c.id] = c
	}

	conflicts := map[int]bool{}

	for xoff := 0; xoff < c.width; xoff++ {
		for yoff := 0; yoff < c.height; yoff++ {
			nx, ny := c.x+xoff, c.y+yoff

			if conflicted {
				// wipe this out
				f[nx][ny] = conflict
			}

			patch := f[nx][ny]
			switch patch {
			case conflict: // claimed at least twice already
				conflicts[c.id] = true

			case 0: // never been claimed. mark with the claim ID temporarily.
				f[nx][ny] = c.id

			default: // claimed by exactly one id previously
				conflicts[patch] = true
				conflicts[c.id] = true
			}
		}
	}

	for id := range conflicts {
		claim := uniqs[id]
		delete(uniqs, id)
		claim.mark(f, true)
	}
}

func newClaim(line string) claim {
	matches := claimRe.FindStringSubmatch(line)
	if len(matches) != 6 {
		panic(fmt.Errorf("invalid number of matches for line '%s': %d. Expected 6", line, len(matches)))
	}

	return claim {
		id: mustConvert(matches[1]),
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
