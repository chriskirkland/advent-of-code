# https://adventofcode.com/2022/day/1
$data = File.read("input.txt").split("\n\n").map{_1.split("\n").map(&:to_i)}
packs = $data.map(&:sum).sort.reverse
puts packs[0]
puts packs.take(3).sum
