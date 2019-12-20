package main

import (
	"fmt"
	"io/ioutil"
	"strings"
)

const (
	inputFileName = "input.txt"

	width = 25
	height = 6
)

func main() {
	dat, err := ioutil.ReadFile(inputFileName)
	if err != nil {
		panic(err)
	}

	pixelsPerLayer := width * height


	lines := strings.Split(string(dat), "\n")
	img := strings.Join(lines, "")

	minZeros, max := 1000 * 1000, 0
	for len(img) > 0 {
		layer := img[:pixelsPerLayer]
		img = img[pixelsPerLayer:]

		if zeros :=  strings.Count(layer, "0"); zeros < minZeros {
			minZeros = zeros
			max = strings.Count(layer, "1")	 * strings.Count(layer, "2")
		}
	}


	fmt.Println(max)
}
