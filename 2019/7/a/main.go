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

type program []int

func fact(n int) int {
	if n == 1 {
		return 1
	}
	return n * fact(n-1)
}

func perms(list string) []string{
	if len(list) == 0 {
		return []string{list}
	}

	ps := make([]string, 0, fact(len(list)))
	for ix, elem := range list {
		sublist := perms(list[0:ix]+list[ix+1:])
		for _, item := range sublist {
			ps = append(ps, string(elem)+item)
		}
	}
	return ps
}

func newProgram() *program {
	p := make(program, 0, 256)
	return &p
}

func (p program) copy() *program {
	np := make(program, 0, len(p))
	for _, val := range p {
		np.add(val)
	}
	return &np
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

func main() {
	dat, err := ioutil.ReadFile(inputFileName)
	if err != nil {
		panic(err)
	}

	/*
		read the input
	*/
	master := newProgram()
	for _, elem := range strings.Split(strings.TrimSpace(string(dat)), ",") {
		val, err := strconv.Atoi(elem)
		if err != nil {
			panic(fmt.Errorf("invalid program format: '%s' not an integer: %s", elem, err.Error()))
		}
		master.add(val)
	}

	max := 0

	sequences := perms("01234")
	for _, sequence := range sequences {
		result := 0

		//fmt.Printf("\ntrying sequence: %v\n", sequence)
		for _, input := range sequence {
			//fmt.Printf("-- inputs: %d %d\n", input-'0', result)
			calls := 0
			inputInstruction := func() int {
				calls++
				switch calls {
				case 1:
					return int(input-'0')
				case 2:
					return result
				default:
					panic("too many input instructions")
				}
			}

			/*
				run the program
			*/
			prog := master.copy()
			pos := 0

		LOOP:
			for {
				iptr := prog.get(pos, 1)
				//fmt.Printf("\n~~~ CURRENT PROGRAM ~~~\n%v\n", (*prog))
				op, modes := iptr%100, iptr/100
				//fmt.Printf("op code '%d', mode '%d' (pos %d)\n", op, modes, pos)
				switch op {
				case 1:
					storeAt := prog.get(pos+3, 1)
					op1 := prog.get(pos+1, modes%10)
					op2 := prog.get(pos+2, modes/10)
					prog.set(storeAt, op1+op2)
				case 2:
					storeAt := prog.get(pos+3, 1)
					op1 := prog.get(pos+1, modes%10)
					op2 := prog.get(pos+2, modes/10)
					prog.set(storeAt, op1*op2)
				case 3:
					prog.set(prog.get(pos+1, 1), inputInstruction())
					pos += 2
					continue
				case 4:
					result = prog.get(pos+1, modes%10)
					pos += 2
					continue
				case 5:
					if prog.get(pos+1, modes%10) != 0 {
						pos = prog.get(pos+2, modes/10)
					} else {
						pos += 3
					}
					continue
				case 6:
					if prog.get(pos+1, modes%10) == 0 {
						pos = prog.get(pos+2, modes/10)
					} else {
						pos += 3
					}
					continue
				case 7:
					storeAt := prog.get(pos+3, 1)
					op1 := prog.get(pos+1, modes%10)
					op2 := prog.get(pos+2, modes/10)
					if op1 < op2 {
						prog.set(storeAt, 1)
					} else {
						prog.set(storeAt, 0)
					}
				case 8:
					storeAt := prog.get(pos+3, 1)
					op1 := prog.get(pos+1, modes%10)
					op2 := prog.get(pos+2, modes/10)
					if op1 == op2 {
						prog.set(storeAt, 1)
					} else {
						prog.set(storeAt, 0)
					}
				case 99:
					break LOOP
				default:
					panic(fmt.Errorf("invalid op code '%d'", op))
				}

				if iptr == prog.get(pos, 1) {
					pos += 4
				}
			}
		}

		if result > max {
			max = result
		}
	}

	fmt.Println(max)
}
