package main

import (
	"fmt"
	"io/ioutil"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"time"
)

const (
	inputFileName = "./input.txt"

	timeFormat     = "2006-01-02 15:04"
)

var shiftRe = regexp.MustCompile(`Guard #(\d+) begins shift`)

func main() {
	dat, err := ioutil.ReadFile(inputFileName)
	if err != nil {
		panic("unable to read file: " + inputFileName)
	}

	lines := strings.Split(string(dat), "\n")
	sort.Strings(lines)

	// guard ID -> asleep "counts"
	//   0-59: times asleep per minute
	//   60: total minutes slept (to avoid another '60*n' pass for the max)
	sleeps := make(map[int]*[61]int)

	var id int
	var startTime time.Time
	for _, line := range lines {
		line = strings.TrimSpace(line)

		t, err := time.Parse(timeFormat, line[1:17])
		check(err)
		action := line[19:]

		switch action {
		case "falls asleep"	:
			startTime =  t

		case "wakes up":
			sleeps[id][60] += t.Minute() - startTime.Minute()
			for i := startTime.Minute(); i < t.Minute(); i++ {
				sleeps[id][i]++
			}

		default: // new guard on shift
			matches := shiftRe.FindStringSubmatch(action)
			if len(matches) != 2 {
				panic(fmt.Sprintf("bad number of matches for shift start '%s': %d", action, len(matches)))
			}
			id, err = strconv.Atoi(matches[1])
			check(err)

			if sleeps[id] == nil {
				sleeps[id] = new([61]int)
			}
		}
	}

	// find the sleepiest guard
	maxGuard, maxSleeps := -1, -1
	for guard, sleepTimes := range sleeps {
		if sleepTimes[60] > maxSleeps {
			maxGuard, maxSleeps = guard, sleepTimes[60]
		}
	}

	// find his sleepiest minute
	bestMinute, maxSleeps := -1, -1
	guardSleeps := sleeps[maxGuard]
	for i := 0; i < 60; i++ {
		if guardSleeps[i] > maxSleeps {
			bestMinute, maxSleeps = i, guardSleeps[i]
		}
	}

	fmt.Printf("guard %d at minute %d = %d\n", maxGuard, bestMinute, bestMinute * maxGuard)
}

func check(err error) {
	if err != nil {
		panic(err)
	}
}
