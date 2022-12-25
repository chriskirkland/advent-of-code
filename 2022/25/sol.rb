# https://adventofcode.com/2022/day/25
$data = File.read("input.txt").split("\n").map(&:chars)

CH_TO_INT = ["2", "1", "0", "-", "="].zip(2.downto(-2)).to_h
INT_TO_CH = CH_TO_INT.invert

def to_snafu(num)
    # start with the base5 representation of the number
    repr = num.to_s(5).chars.map(&:to_i).reverse

    # make a snafu
    digit = 0
    while digit < repr.size
        unless repr[digit] <= 2
            repr[digit+1] ||= 0
            repr[digit+1] += 1
            repr[digit] = repr[digit] - 5
        end
        digit += 1
    end
    repr.reverse.map { |digit| INT_TO_CH[digit] }.join
end

puts to_snafu $data.map { |num|
    num.reverse.map.with_index { |digit, i|
        CH_TO_INT[digit] * 5**i
    }
}.flatten.sum
