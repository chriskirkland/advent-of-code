package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

const (
	inputFileName = "../input.txt"

	MAX_NOUN_OR_VERB = 99
)


func main() {
	dat, err := ioutil.ReadFile(inputFileName)
	if err != nil {
		panic(err)
	}

	master := make([]uint, 0, 256)
	for _, elem := range strings.Split(strings.TrimSpace(string(dat)), ",") {
		val, err := strconv.Atoi(elem)
		if err != nil {
			panic(fmt.Errorf("invalid program format: '%s' not an integer: %s", elem, err.Error()))
		}
		master = append(master, uint(val))
	}

	program := make([]uint, len(master))
	//TODO(cmkirkla): can we prune this?
	for noun := uint(0); noun <= MAX_NOUN_OR_VERB; noun++ {
		for verb := uint(0); verb <= MAX_NOUN_OR_VERB; verb++ {
			// fresh program
			for ix, elem := range master {
				program[ix] = elem
			}

			// mutate
			program[1], program[2] = noun, verb

			// run
			result := run(program)

			// check result
			//fmt.Printf("(%d,%d) -> %d\n", noun, verb, result)
			if result == 19690720 {
				fmt.Println(100 * noun + verb)
				return
			}
		}
	}

}

func run(program []uint) uint {
LOOP:
	for pos := 0; ; pos += 4 {
		op, inPos1, inPos2, outPos := program[pos], program[pos+1], program[pos+2], program[pos+3]
		//fmt.Printf("executing '%d %d %d %d' (at pos %d)\n", op, inPos1, inPos2, outPos, pos)
		switch op {
		case 1:
			program[outPos] = program[inPos1] + program[inPos2]
		case 2:
			program[outPos] = program[inPos1] * program[inPos2]
		case 99:
			break LOOP // halt
		default:
			panic(fmt.Errorf("invalid op code '%d'", op))
		}
	}

	/*
	result := make([]string, len(program))
	for ix, elem := range program {
		result[ix] = strconv.Itoa(int(elem))
	}
	fmt.Println(strings.Join(result, ",") + "\n")
	 */

	return program[0]
}
