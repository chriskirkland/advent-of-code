package main

import (
	"fmt"
	"io"
	"os"
)

const (
	inputFileName = "../input.txt"
	size          = 400
	maxDistance   = 10000
)

func main() {
	f, err := os.Open(inputFileName)
	if err != nil {
		panic(err)
	}
	defer f.Close()

	grid := &[size][size]int{}

	var id, x, y int
	for {
		id++

		_, err = fmt.Fscanf(f, "%d, %d", &x, &y)
		if err != nil {
			if err == io.EOF {
				break
			}
			panic(err)
		}

		if x < 0 || x >= size || y < 0 || y >= size {
			panic(fmt.Errorf("invalid starting coordinates (%d,%d)", x, y))
		}

		propogate(grid, id, x, y)

		//print(grid)
		//fmt.Println()
	}

	// there are ways to keep track as we propogate above, but they're impractical for the given input size
	var goodArea int
	for i := 0; i < size; i++ {
		for j := 0; j < size; j++ {
			if grid[i][j] < maxDistance {
				goodArea++
			}
		}
	}

	fmt.Printf("total good area %d\n", goodArea)
}

// update each point in the grid with the distance to the current point (x,y) proviced it's the closest or tied
func propogate(grid *[size][size]int, id, x, y int) {
	for i := 0; i < size; i++ {
		// start from the middle and work out to (hopefully) minimize cases were explore long "bounding regions" on the edges
		for j := 0; j < size; j++ {
			grid[i][j] += dist(x, y, i, j)
		}
	}
}

func dist(x, y, xp, yp int) int {
	return abs(xp-x) + abs(yp-y)
}

func abs(a int) int {
	if a > 0 {
		return a
	}
	return -a
}

func print(grid *[size][size]int) {
	for i := 0; i < size; i++ {
		for j := 0; j < size; j++ {
			coord := grid[i][j]
			if coord < maxDistance {
				fmt.Print("#")
			} else {
				fmt.Print(".")
			}
		}
		fmt.Println()
	}
}
