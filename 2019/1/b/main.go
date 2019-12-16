package main

import (
	"fmt"
	"io"
	"os"
)

const (
	inputFileName = "../input.txt"
)

func main() {
	f, err := os.Open(inputFileName)
	if err != nil {
		panic(err)
	}
	defer f.Close()

	var mass, fuel int
	for {
		_, err = fmt.Fscanf(f, "%d", &mass)
		if err != nil {
			if err == io.EOF || err == io.ErrUnexpectedEOF {
				break
			}
			panic(err)
		}

		for fuelMass := fn(mass); fuelMass > 0; fuelMass = fn(fuelMass) {
			fmt.Printf("%d fuel mass remaining\n", fuelMass)
			fuel += fuelMass
		}
		fmt.Printf("%d fuel required after %d mass\n\n", fuel, mass)
	}

	fmt.Println(fuel)
}

func fn(mass int) int {
	return mass/3 - 2
}
