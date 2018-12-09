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
	//   60: minute slept most frequently
	//   61: times sleep for max frequenty minute (^)
	sleeps := make(map[int]*[62]int)

	var id int
	var startTime time.Time
	for _, line := range lines {
		line = strings.TrimSpace(line)

		t, err := time.Parse(timeFormat, line[1:17])
		check(err)
		action := line[19:]
		//fmt.Printf("'%s' at %v\n", action, t)

		switch action {
		case "falls asleep"	:
			startTime =  t

		case "wakes up":
			sleeps[id][60] += t.Minute() - startTime.Minute()
			for i := startTime.Minute(); i < t.Minute(); i++ {
				sleeps[id][i]++
				if sleeps[id][i] > sleeps[id][61] {
					sleeps[id][60] = i
					sleeps[id][61] = sleeps[id][i]
				}
			}

		default: // new guard on shift
			matches := shiftRe.FindStringSubmatch(action)
			if len(matches) != 2 {
				panic(fmt.Sprintf("bad number of matches for shift start '%s': %d", action, len(matches)))
			}
			id, err = strconv.Atoi(matches[1])
			check(err)

			if sleeps[id] == nil {
				sleeps[id] = new([62]int)
			}
		}
	}

	// find the sleepiest guard
	maxGuard, maxSleeps := -1, -1
	for guard, sleepTimes := range sleeps {
		if sleepTimes[61] > maxSleeps {
			maxGuard, maxSleeps = guard, sleepTimes[61]
		}
	}

	fmt.Printf("guard %d at minute %d (%d times) = %d\n", maxGuard, sleeps[maxGuard][60], sleeps[maxGuard][61], maxGuard * sleeps[maxGuard][60])
}

func check(err error) {
	if err != nil {
		panic(err)
	}
}
