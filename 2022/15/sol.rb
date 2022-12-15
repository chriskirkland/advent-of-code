# https://adventofcode.com/2022/day/15
require 'set'
$data = File.read("input.txt").split("\n").map { |line|
    line.scan(/(-?\d+)/).flatten.map(&:to_i).each_slice(2).to_a
}

def dist(a,b)
    (a[0]-b[0]).abs + (a[1]-b[1]).abs
end

def union(r1, r2)
    Range.new([r1.begin, r2.begin].min, [r1.end, r2.end].max)
end

# returns a list of maximal disjoin ranges from the provided list of ranges
def shrink(ranges)
    nranges = []
    sorted = ranges.sort_by(&:begin)
    while sorted.size > 1
        r1, r2 = sorted[0], sorted[1]
        unless r1.end >= r2.begin-1
            nranges.push sorted.shift
            next
        end

        sorted.shift(2)
        sorted.unshift union(r1, r2)
    end
    nranges + sorted
end

# part 1
LINE = 2000000
def solve_p1()
    covered = []
    beacons = Set.new
    $data.each do |s, b|
        beacons.add b[0] if b[1] == LINE 

        dtb = dist(s,b) # distance to beacon
        dtl = (s[1]-LINE).abs # vertical distance to line
        rem = dtb-dtl
        next if dtl > dtb

        # mark all the points on the line covered by this source
        covered.push Range.new(s[0]-rem, s[0]+rem)
    end
    covered = shrink(covered).map(&:size).sum
    covered-beacons.size
end

# part 2
MAX=4000000
def solve_p2()
    (0..MAX).each do |y|
        covered = []
        $data.each do |s, b|
            dtb = dist(s,b) # distance to beacon
            dtl = (s[1]-y).abs # vertical distance to line
            rem = dtb-dtl
            next if dtl > dtb

            # mark all the points on the line covered by this source
            covered.push Range.new([0, s[0]-rem].max, [MAX, s[0]+rem].min)
        end

        covered = shrink(covered)
        if covered.size > 1
            x = covered[0].end+1
            return 4000000 * (covered[0].end+1) + y  
        elsif covered.size == 1 && covered[0].begin > 0
            return y
        elsif covered.size == 1 && covered[0].end < MAX
            return 4000000 * MAX + y
        end
    end
end

puts solve_p1
puts solve_p2