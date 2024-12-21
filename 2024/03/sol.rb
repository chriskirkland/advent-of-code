# https://adventofcode.com/2024/day/3
$data = File.read("input.txt")
p1 = $data.scan(/mul\(\d+,\d+\)/).map do |inst|
    inst.scan(/\d+/).map(&:to_i).reduce(:*)
end.sum
puts p1

enabled = true
p2 = $data.scan(/(do\(\)|don't\(\)|mul\(\d+,\d+\))/).map do |inst|
    grp = inst[0]
    val = if grp == "do()"
        enabled = true
    elsif grp == "don't()"
        enabled = false
    elsif enabled
        grp.scan(/\d+/).map(&:to_i).reduce(:*)
    end
    val.is_a?(Integer) ? val : 0
end.sum
puts p2


