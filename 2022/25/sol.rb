# https://adventofcode.com/2022/day/25
$data = File.read("input.txt").split("\n").map(&:chars)

CH_TO_INT = ["2", "1", "0", "-", "="].zip(2.downto(-2)).to_h
INT_TO_CH = CH_TO_INT.invert

def to_snafu(num)
    # start with the base5 representation of the number, unset digits are 0
    repr = num.to_s(5).chars.map(&:to_i).reverse

    # make a snafu
    digit = 0
    while digit < repr.size
        #puts "[#{num}, d#{digit}] BEFORE #{repr}"
        if repr[digit] <= 2  # nothing to do
            digit += 1
            next
        end

        repr[digit+1] ||= 0
        repr[digit+1] += 1
        repr[digit] = repr[digit] - 5
        digit += 1
    end
    repr.reverse.map { |digit| INT_TO_CH[digit] }.join
end

def check(v, exp)
    s = to_snafu(v)
    return if s == exp
    puts "Wrong answer for #{v}"
    puts "  expected #{exp}"
    puts "  found    #{s}"
end

#check(1, "1")
#check(2, "2")
#check(3, "1=")
#check(4, "1-")
#check(5, "10")
#check(6, "11")
#check(7, "12")
#check(8, "2=")
#check(9, "2-")
#check(10, "20")
#check(15, "1=0")
#check(20, "1-0")
#check(2022, "1=11-2")
#check(12345, "1-0---0")
#check(314159265, "1121-1110-1=0")


total = $data.map { |num|
    num.reverse.map.with_index { |digit, i|
        CH_TO_INT[digit] * 5**i
    }
}.flatten.sum
puts total
puts to_snafu(total)
