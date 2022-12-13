# https://adventofcode.com/2022/day/13
$data = File.read("input.txt").split("\n\n").map{ _1.split("\n") }

# -1 if a < b, 0 if a == b, 1 if a > b
def cmp(a, b)
    return 0 if a == b
    if a.is_a?(Integer) && b.is_a?(Integer)
        return a < b ? -1 : 1
    end
    return cmp([a], b) if a.is_a?(Integer)
    return cmp(a, [b]) if b.is_a?(Integer)

    len = [a.length, b.length].min
    len.times do |i|
        val = cmp(a[i], b[i])
        return val if val != 0
    end
    a.count <= b.count ? -1 : 1
end

# part 1
puts $data.each_with_index.map { |pair, ix|
    l, r = eval(pair[0]), eval(pair[1])
    ix+1 if cmp(l,r) <= 0
}.compact.sum

# part 2
d1, d2 = [[2]], [[6]]
all = $data.flatten(1).map{eval(_1)}.push(d1).push(d2).sort { |a, b| cmp(a, b) }
puts all.each_with_index.map { |packet, ix| 
    ix+1 if packet == d1 || packet == d2 
}.compact.inject(:*)
