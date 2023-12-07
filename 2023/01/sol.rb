# https://adventofcode.com/2022/day/1
$data = File.read("input.txt").split("\n")
#$data = File.read("sample.txt").split("\n")

### part 1

cvs = $data.map do |line|
    d = line.scan(/\d/)
    (d[0] + d[-1]).to_i
end
puts cvs.sum

### part 2
digits = {
    "one" => 1,
    "two" => 2,
    "three" => 3,
    "four" => 4,
    "five" => 5,
    "six" => 6,
    "seven" => 7,
    "eight" => 8,
    "nine" => 9,
}
(1..9).each { |i| digits[i.to_s] = i }

re = "(" + digits.keys.join("|") + ")"
rre = "(" + digits.keys.join("|").reverse + ")"

cvs = $data.map do |line|
    d1 = line.scan(/#{re}/)[0][0]
    d2 = line.reverse.scan(/#{rre}/)[0][0].reverse
    10 * digits[d1] + digits[d2]
end
puts cvs.sum