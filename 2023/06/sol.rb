# https://adventofcode.com/2022/day/6

#$data = File.read("sample.txt").split("\n")
$data = File.read("input.txt").split("\n")

### part 1

races = $data.map do |line|
    line.scan(/\d+/).map(&:to_i)
end.transpose

wins_per_race = races.map do |time, record|
    (1..time-1).map do |wait|
        wait * (time-wait) > record
    end.count(true)
end
puts wins_per_race.reduce(:*)

### part 2 (brute force for the win)
# probably should do binary search for the boundaries... but who has the time?

time, record = $data.map do |line|
    line.scan(/\d+/).join('').to_i
end

wins = (1..time-1).map do |wait|
    wait * (time-wait) > record
end.count(true)
puts wins
