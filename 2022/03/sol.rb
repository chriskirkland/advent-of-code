require 'set'

def score(c)
    if c.ord >= 'a'.ord
        c.ord - 'a'.ord + 1
    else
        c.ord - 'A'.ord + 26 + 1
    end
end

data = File.read('input.txt').split("\n").map(&:chars)

p1_bags = data.map {_1.each_slice(_1.length/2)}.map(&:to_a)
misplaced = p1_bags.map { |bag|
    c1, c2 = bag.map(&:to_set)
    c1.intersection(c2).to_a.first
}
p1 = misplaced.map{score(_1)}.sum
puts "Part 1: #{p1}"

p2_bags = data.each_slice(3).to_a
common = p2_bags.map { |bags|
    b1, b2, b3 = bags.map(&:to_set)
    b1.intersection(b2).intersection(b3).to_a.first
}
p2 =  common.map{score(_1)}.sum
puts "Part 2: #{p2}"


