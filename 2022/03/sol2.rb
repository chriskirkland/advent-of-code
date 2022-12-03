require 'set'

data = File.read('input.txt').split("\n").map(&:chars)

SCORE = Hash[('a'..'z').zip(1..26) + ('A'..'Z').zip(27..52)]

p1_bags = data.map {_1.each_slice(_1.length/2)}.map(&:to_a)
puts p1_bags.map { |c1,c2| SCORE[(c1&c2).first] }.sum

p2_bags = data.each_slice(3).to_a
puts p2_bags.map { |b1,b2,b3| SCORE[(b1&b2&b3).to_a.first] }.sum

