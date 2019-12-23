package main

import (
	"bufio"
	"fmt"
	"io/ioutil"
	"os"
	"strconv"
	"strings"
)

const (
	inputFileName = "../input.txt"
)

type program []int

func newProgram() *program {
	p := make(program, 0, 256)
	return &p
}

func (p program) get(position, mode int) int {
	val := p[position]
	switch mode {
	case 0:
		return p[val] // use the program value as an address
	case 1:
		return val // use the program value as a literal
	default:
		panic(fmt.Errorf("invalid program mode '%d'", mode))
	}
}

func (p *program) set(position, value int) {
	(*p)[position]	= value
}

func (p *program) add(value int) {
	*p = append(*p, value)
}

func requestIntInput() int {
	reader := bufio.NewReader(os.Stdin)
	fmt.Print("input requested> ")

	input, err := reader.ReadString('\n')
	if err != nil {
		panic(err)
	}

	val, err := strconv.Atoi(strings.TrimSuffix(input, "\n"))
	if err != nil {
		panic(err)
	}
	return val
}

func main() {
	dat, err := ioutil.ReadFile(inputFileName)
	if err != nil {
		panic(err)
	}

	/*
		read the input
	*/
	inputInstruction := requestIntInput()

	prog := newProgram()
	for _, elem := range strings.Split(strings.TrimSpace(string(dat)), ",") {
		val, err := strconv.Atoi(elem)
		if err != nil {
			panic(fmt.Errorf("invalid program format: '%s' not an integer: %s", elem, err.Error()))
		}
		prog.add(val)
	}

	/*
		run the program
	*/
	pos := 0
	for {
		//fmt.Printf("\n~~~ CURRENT PROGRAM ~~~\n%v\n", (*prog)[0:pos+4])
		op, modes := prog.get(pos, 1) % 100, prog.get(pos,1) / 100
		//fmt.Printf("op code '%d', mode '%d' (pos %d)\n", op, modes, pos)
		switch op {
		case 1:
			storeAt := prog.get(pos+3, 1)
			op1 := prog.get(pos+1, modes % 10)
			op2 := prog.get(pos+2, modes / 10)
			prog.set(storeAt, op1+op2)
			pos += 4
		case 2:
			storeAt := prog.get(pos+3, 1)
			op1 := prog.get(pos+1, modes % 10)
			op2 := prog.get(pos+2, modes / 10)
			prog.set(storeAt, op1*op2)
			pos += 4
		case 3:
			prog.set(prog.get(pos+1,1), inputInstruction)
			pos += 2
		case 4:
			fmt.Println(prog.get(pos+1, modes % 10))
			pos += 2
		case 99:
			return
		default:
			panic(fmt.Errorf("invalid op code '%d'", op))
		}

	}
}
