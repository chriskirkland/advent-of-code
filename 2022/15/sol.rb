# https://adventofcode.com/2022/day/15
$data = File.read("input.txt").split("\n").map { |line|
    line.scan(/(-?\d+)/).flatten.map(&:to_i).each_slice(2).to_a
}

def dist(a,b)
    (a[0]-b[0]).abs + (a[1]-b[1]).abs
end

require 'set'
covered = Set.new
exempt = Set.new

LINE = 2000000
$data.each do |s, b|
    puts "s=#{s} b=#{b}"
    exempt.add b[0] if b[1] == LINE 

    dtb = dist(s,b) # distance to beacon
    dtl = (s[1]-LINE).abs # vertical distance to line
    next if dtl > dtb
    
    # mark all the points on the line covered by this source
    cbs = 0.upto(dtb-dtl).map { |i| [s[0]-i, s[0]+i] }.flatten
    puts "  covered: #{cbs.uniq.size}"
    covered += cbs
end
puts (covered-exempt).size