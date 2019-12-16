package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

const (
	inputFileName = "../input.txt"
)

func main() {
	dat, err := ioutil.ReadFile(inputFileName)
	if err != nil {
		panic(err)
	}

	/*
		read the input
	*/

	program := make([]uint, 0, 256)
	for _, elem := range strings.Split(strings.TrimSpace(string(dat)), ",") {
		val, err := strconv.Atoi(elem)
		if err != nil {
			panic(fmt.Errorf("invalid program format: '%s' not an integer: %s", elem, err.Error()))
		}
		program = append(program, uint(val))
	}

	/*
		restore to crash state
	 */
	program[1], program[2] = 12, 2

	/*
		run the program
	*/
LOOP:
	for pos := 0; ; pos += 4 {
		op, inPos1, inPos2, outPos := program[pos], program[pos+1], program[pos+2], program[pos+3]
		fmt.Printf("executing '%d %d %d %d' (at pos %d)\n", op, inPos1, inPos2, outPos, pos)
		switch op {
		case 1:
			program[outPos] = program[inPos1] + program[inPos2]
		case 2:
			program[outPos] = program[inPos1] * program[inPos2]
		case 99:
			break LOOP
		default:
			panic(fmt.Errorf("invalid op code '%d'", op))
		}
	}

	result := make([]string, len(program))
	for ix, elem := range program {
		result[ix] = strconv.Itoa(int(elem))
	}
	fmt.Println(strings.Join(result, ","))
}
