package main

import (
	"fmt"
	"io"
	"os"
)

const (
	inputFileName = "../input.txt"
	size          = 400
)

type mark struct {
	id   int
	dist int
}

func main() {
	f, err := os.Open(inputFileName)
	if err != nil {
		panic(err)
	}
	defer f.Close()

	grid := &[size][size]*mark{}

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

	// calculate the area for each ID
	areas := make(map[int]int, id)
	for i := 0; i < size; i++ {
		for j := 0; j < size; j++ {
			areas[grid[i][j].id]++
		}
	}

	// mark all IDs on the perimeter as infinite
	for i := 0; i < size; i++ {
		delete(areas, grid[0][i].id)
		delete(areas, grid[size-1][i].id)
		delete(areas, grid[i][0].id)
		delete(areas, grid[i][size-1].id)
	}
	delete(areas, 0) // tied

	maxID, max := -1, -1
	for id, area := range areas {
		if area > max {
			maxID = id
			max = area
		}
	}

	fmt.Printf("point %d has area %d\n", maxID-1, max)
}

// update each point in the grid with the distance to the current point (x,y) proviced it's the closest or tied
func propogate(grid *[size][size]*mark, id, x, y int) {
	for i := 0; i < size; i++ {
		// start from the middle and work out to (hopefully) minimize cases were explore long "bounding regions" on the edges
		for j := size/2 + 1; j < size; j++ {
			curr := grid[i][j]
			switch {
			case curr == nil:  // coordinate never marked
				fallthrough
			case curr.dist > dist(x, y, i, j):  // coordinate marked by farther dangerous point
				grid[i][j] = &mark{
					id:   id,
					dist: dist(x, y, i, j),
				}

			case curr.dist == dist(x, y, i, j):  // equidistant to another dangerous point
				curr.id = 0
				break  // bounded on this row

			case curr.dist < dist(x, y, i, j):  // closer to another dangerous point
				break  // bounded on this row
			}
		}

		for j := size / 2; j >= 0; j-- {
			curr := grid[i][j]
			switch {
			case curr == nil:
				fallthrough
			case curr.dist > dist(x, y, i, j):
				grid[i][j] = &mark{
					id:   id,
					dist: dist(x, y, i, j),
				}

			case curr.dist == dist(x, y, i, j):
				curr.id = 0
				break  // bounded on this row

			case curr.dist < dist(x, y, i, j):
				break  // bounded on this row
			}
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

func print(grid *[size][size]*mark) {
	for i := 0; i < size; i++ {
		for j := 0; j < size; j++ {
			coord := grid[i][j]
			switch {
			case coord == nil:
				fmt.Print('N')
			case coord.id == 0:
				fmt.Print('.')
			default:
				fmt.Print(coord.id)
			}
		}
		fmt.Println()
	}
}

