# https://adventofcode.com/2024/day/1
$data = File.read("input.txt").split("\n")
lists = $data.map do |line|
    line.scan(/\d+/).map(&:to_i)
end.transpose
N = lists[0].size
lists.map! do |list|
    list.sort
end

p1 = 0.upto(N-1).map do |i|
    (lists[0][i] - lists[1][i]).abs
end.sum

puts p1

freq = lists[1].tally
p2 = 0.upto(N-1).map do |i|
    lists[0][i] * (freq[lists[0][i]] || 0)
end.sum
puts p2