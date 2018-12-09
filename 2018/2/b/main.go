package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"strings"
)

const inputFileName = "../input.txt"

type key struct {
	index  int
	common string
}

func main() {
	dat, err := ioutil.ReadFile(inputFileName)
	if err != nil {
		panic("unable to read file: " + inputFileName)
	}

	partials := make(map[key]string)

	lines := strings.Split(string(dat), "\n")

	// populate map of partial IDs
	for _, id := range lines {
		id = strings.TrimSpace(id)
		for _, pkey := range getPartials(id) {
			prev, ok := partials[pkey]
			if ok {
				// found the common pair (prev, id)
				fmt.Printf("'%s' and '%s' share '%s'\n", prev, id, pkey.common)
				os.Exit(0)
			}
			partials[pkey] = id
		}
	}
}

func getPartials(s string) []key {
	partials := make([]key, len(s))
	for ix := range s {
		pkey := key{
			index:  ix,
			common: s[:ix],
		}
		if ix < len(s)-1 {
			pkey.common += s[ix+1:]
		}
		partials[ix] = pkey
	}
	return partials
}
