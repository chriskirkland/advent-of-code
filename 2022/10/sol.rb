# https://adventofcode.com/2022/day/10
$data = File.read("input.txt").split("\n").map(&:split)

# generate values of x register at each clock cycle
x = 1
xvals = $data.map { |instr|
    next x if instr[0] == "noop"

    v = [x,x]
    x += instr[1].to_i
    v
}.insert(x).flatten

# part 1
CYCLES = [20, 60, 100, 140, 180, 220]
puts CYCLES.map { |c| c * xvals[c-1] }.reduce(:+) 

# part 2
pixels = xvals.each_with_index.map { |v, c|
    next "#" if (c%40-v).abs <= 1
    "."
}
puts pixels.each_slice(40).map(&:join).join("\n")
