# https://adventofcode.com/2022/day/4
$data = File.read("input.txt").split("\n")

score = Array.new($data.length, 0)
copies = Array.new($data.length, 1)

$data.each_with_index do |line, card|
    _, _, wins, _, numbers = line.split(/(:|\|)/)
    winners = wins.split(" ").intersection(numbers.split(" "))
    score[card] = 1 << (winners.length-1)
    1.upto(winners.length) do |offset|
        copies[card+offset] += copies[card]
    end
end

puts "p1: #{score.sum}"
puts "p2: #{copies.sum}"