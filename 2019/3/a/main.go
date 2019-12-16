package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

const (
	inputFileName = "../input.txt"

	MAX = 50000
)

func main() {
	dat, err := ioutil.ReadFile(inputFileName)
	if err != nil {
		panic(err)
	}

	// grid in first quadrant
	// X is left to right
	// Y is down to up
	var grid [MAX][MAX]bool

	lines := strings.Split(string(dat), "\n")
	w1 := strings.Split(lines[0], ",")
	w2 := strings.Split(lines[1], ",")

	origin := MAX/2
	min := 2 * MAX + 1

	first := true

	var x, y, dx, dy int
	for _, wire := range [][]string{w1, w2}{
		fmt.Println("starting new wire")

		// reset to origin
		x, y = origin, origin

		for _, strand := range wire {
			/*
				read in details for strand of wire
			 */
			dir, lenStr := strand[0], strand[1:]
			len, err := strconv.Atoi(lenStr)
			if err != nil {
				panic(fmt.Errorf("invalid wire length '%s': %s", lenStr, err.Error()))
			}

			switch dir{
			case 'R':
				dx,dy = 1, 0
			case 'L':
				dx,dy = -1, 0
			case 'U':
				dx,dy = 0, 1
			case 'D':
				dx,dy = 0, -1
			default:
				panic(fmt.Errorf("invalid direction '%s'", string(dir)))
			}

			/*
				trace wire marking locations
			 */
			fmt.Printf("tracing '%d' steps '%s'\n", len, string(dir))
			for i := 0; i < len; i++ {
				x, y = x+dx, y+dy
				if first {
					grid[x][y] = true
				} else if grid[x][y] {
					dist := abs(x-origin) + abs(y-origin)
					fmt.Printf("wires crossed at (%d,%d) with distance %d\n", x, y, dist)
					if dist < min {
						min = dist
					}
				}
			}
		}
		fmt.Println()

		first = false
	}

	fmt.Printf("minimum crossing distance is %d", min)
}

func abs(x int) int {
	if x>0 {
		return x
	}
	return -x
}
