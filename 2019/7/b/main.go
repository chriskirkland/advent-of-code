package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
	"sync"
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

func perms(list string) []string {
	if len(list) == 0 {
		return []string{list}
	}

	ps := make([]string, 0, fact(len(list)))
	for ix, elem := range list {
		sublist := perms(list[0:ix] + list[ix+1:])
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
	(*p)[position] = value
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

	sequences := perms("56789")
	for _, sequence := range sequences{
		//fmt.Printf("\ntrying sequence: %v\n", sequence)

		wg := new(sync.WaitGroup)

		/*
			start amplifiers
		*/
		inputs := make([]chan int, 5)
		outputs := make([]chan int, 5)
		done := make(chan bool)
		for ix := 0; ix < 5; ix++ {
			inputs[ix] = make(chan int)
			outputs[ix] = make(chan int)

			wg.Add(1)
			go newAmplifier(master.copy(), 'A' + ix, inputs[ix], outputs[ix], wg)
		}

		/*
			wire up feedback loop
		 */
		for ix := 0; ix < 5; ix ++ {
			go func(ix int, to chan<- int, from <-chan int) {
				for {
					select {
					case <-done:
						return
					case val, ok := <-from:
						if !ok {
							from = nil // disable this case
							continue
						}
						to <- val
					}
				}
			}(ix, inputs[ix], outputs[(ix+4) % 5])
		}

		/*
			kick off system
		 */
		for ix := 0; ix < 5; ix++ {
			inputs[ix] <- int(sequence[ix] - '0')
		}
		inputs[0] <- 0

		/*
			wait until system halts
		 */
		wg.Wait()
		close(done)

		/*
			read last value from feedback loop
		 */
		result := <- inputs[0]
		fmt.Printf("got %d from %s\n", result, sequence)
		if result > max {
			max = result
		}
	}

	fmt.Println(max)
}

func newAmplifier(p *program, name int, input <-chan int, output chan<- int, wg *sync.WaitGroup) {
	defer func() {
		wg.Done()
		close(output)
	}()

	/*
	logf := func(pattern string, args ...interface{}) {
		fmt.Printf("[%c] "+pattern, append([]interface{}{name}, args...)...)
	}
	logn := func(pattern string) {
		fmt.Printf("[%c] "+pattern+"\n", name)
	}
	 */

	pos := 0
	for {
		iptr := p.get(pos, 1)

		//logn("~~~ CURRENT PROGRAM ~~~")
		//logf("%v\n", (*p))

		op, modes := iptr%100, iptr/100
		//logf("op code '%d', mode '%d' (pos %d)\n", op, modes, pos)
		switch op {
		case 1:
			storeAt := p.get(pos+3, 1)
			op1 := p.get(pos+1, modes%10)
			op2 := p.get(pos+2, modes/10)
			p.set(storeAt, op1+op2)
		case 2:
			storeAt := p.get(pos+3, 1)
			op1 := p.get(pos+1, modes%10)
			op2 := p.get(pos+2, modes/10)
			p.set(storeAt, op1*op2)
		case 3:
			//logn("waiting on input")
			in := <-input
			//logf("recieved input %d\n", in)
			p.set(p.get(pos+1, 1), in)
			pos += 2
			continue
		case 4:
			out := p.get(pos+1, modes%10)
			//logf("sending output %d\n", out)
			output <- out
			//logf("sent output %d\n", out)
			pos += 2
			continue
		case 5:
			if p.get(pos+1, modes%10) != 0 {
				pos = p.get(pos+2, modes/10)
			} else {
				pos += 3
			}
			continue
		case 6:
			if p.get(pos+1, modes%10) == 0 {
				pos = p.get(pos+2, modes/10)
			} else {
				pos += 3
			}
			continue
		case 7:
			storeAt := p.get(pos+3, 1)
			op1 := p.get(pos+1, modes%10)
			op2 := p.get(pos+2, modes/10)
			if op1 < op2 {
				p.set(storeAt, 1)
			} else {
				p.set(storeAt, 0)
			}
		case 8:
			storeAt := p.get(pos+3, 1)
			op1 := p.get(pos+1, modes%10)
			op2 := p.get(pos+2, modes/10)
			if op1 == op2 {
				p.set(storeAt, 1)
			} else {
				p.set(storeAt, 0)
			}
		case 99:
			//logn("HALTED!")
			return
		default:
			panic(fmt.Errorf("invalid op code '%d'", op))
		}

		if iptr == p.get(pos, 1) {
			pos += 4
		}
	}
}
