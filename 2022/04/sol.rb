data = File.read('input.txt').gsub('-','..').split("\n")

pairs = data.map { |pair|
  pair.split(",").map{eval(_1)}.map(&:to_a)
}
p1 = pairs.count { |p|
  [p[0].length,p[1].length].min == (p[0]&p[1]).length
}
puts "Part 1: #{p1}"

p2 = pairs.count { |p| 
    (p[0]&p[1]).any?
}
puts "Part 2: #{p2}"