# https://adventofcode.com/2022/day/13
require 'json'
$data = File.read("input.txt").squeeze("\n").split("\n").map(&:strip).map { JSON.parse(_1) }

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
puts $data.each_slice(2).with_index.map { |(l, r), ix|
    ix+1 if cmp(l, r) <= 0
}.compact.sum

# part 2
d1, d2 = [[2]], [[6]]
signal = $data.push(d1).push(d2)
d1ix = signal.map{ cmp(_1, d1) }.count(-1)
d2ix = signal.map{ cmp(_1, d2) }.count(-1) 
puts (d1ix+1) * (d2ix+1)
