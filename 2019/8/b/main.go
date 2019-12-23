package main

import (
	"fmt"
	"io/ioutil"
	"strings"
)

const (
	inputFileName = "input.txt"

	width  = 25
	height = 6
)

func main() {
	dat, err := ioutil.ReadFile(inputFileName)
	if err != nil {
		panic(err)
	}

	pixelsPerLayer := width * height

	lines := strings.Split(string(dat), "\n")
	imgData := strings.Join(lines, "")

	left := make(map[int]bool)
	for ix := 0; ix < pixelsPerLayer; ix++ {
		left[ix] = true
	}

	img := make([]byte, pixelsPerLayer)
	for len(left) > 0 && len(imgData) > 0 {
		layer := imgData[:pixelsPerLayer]
		imgData = imgData[pixelsPerLayer:]

		for pix := range left {
			pixel := layer[pix]
			img[pix] = pixel
			switch pixel {
			case '0', '1':
				delete(left, pix)
			}
		}
	}

	for pos := 0; pos < width * height; pos += width {
		fmt.Println(strings.Replace( string(img[pos:pos+width]) , "0", " ", -1))
	}
}
