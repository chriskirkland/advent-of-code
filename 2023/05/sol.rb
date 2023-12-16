# https://adventofcode.com/2022/day/5
$data = File.read("input.txt").split("\n\n")

$N = 7
$MAPS = Array($N) { nil }

class RangeFunction
    # collection of dijoint, closed ranges on both input and output domains
    # { [Range] -> [Range] }
    def initialize(rangeMap)
        @map = rangeMap
    end

    def do(range)
        drange = partition(range)
        drange.map { |r| map(r) }
    end

    # partitions range based on input ranges in @map. the return ranges in the partition will be covered by some
    # source range in @map
    def partition(range)
        return [range] if range.size == 1

        break_points = @map.map { |r, _| [r.begin, r.end] }.flatten.sort
        int_points = break_points.select { |p| range.include?(p) }
        return [range] if int_points.empty?

        new_points = (int_points + [range.begin, range.end]).sort.uniq
        new_points.each_cons(2).map { |a, b| Range.new(a, b) }
    end

    # transforms the list of ranges based on the range mappings in @map
    # [range, ...]
    def map(range)
        @map.each do |src, dst|
            next unless src.cover?(range) 

            offset = range.begin - src.begin
            nstart = dst.begin + offset
            return Range.new(nstart, nstart + (range.size - 1))
        end

        range
    end
end

# populate each of the maps (e.g. seed-to-soil)
0.upto($N-1) do |mx|
    mappings = $data[mx+1].split("\n").drop(1).map do |line|
        dst, src, len = line.scan(/\d+/).map(&:to_i)
        [Range.new(src, src+len-1), Range.new(dst, dst+len-1)]
    end
    $MAPS[mx] = RangeFunction.new(mappings)
end

def solve(ranges)
    0.upto($N-1) do |mx|
        ranges = ranges.map { |r| $MAPS[mx].do(r) }.flatten
    end
    ranges
end

p1_seeds = $data[0].scan(/\d+/).map(&:to_i)
p1_seed_ranges = p1_seeds.sort.map {|val| Range.new(val, val) }
p1_locations = solve(p1_seed_ranges)
puts "p1: #{p1_locations.map(&:begin).min}"


p2_seed_ranges = $data[0].scan(/\d+/).map(&:to_i).each_slice(2).map do |start, rng|
    Range.new(start, start+rng-1)
end
p2_locations = solve(p2_seed_ranges)
puts "p2: #{p2_locations.map(&:begin).min}"