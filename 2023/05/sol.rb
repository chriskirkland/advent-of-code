# https://adventofcode.com/2022/day/5
$data = File.read("input.txt").split("\n\n")
#$data = File.read("sample.txt").split("\n\n")

N = 7
maps = Array(N) { nil }

p1_seeds = $data[0].scan(/\d+/).map(&:to_i)

#p2_seeds = $data[1].scan(/\d+/).map(&:to_i).each_slice(2) do |start, rng|
#    (start..start+rng).to_a
#end.flatten

# [range] -> { disjoint ranges }
def newMapFunc(mappings) 
    return lambda do |range|
        rs = []
        mappings.each do |src, dst|
            next unless src.include?(range.begin) || src.include?(range.end)

        end
        return val
    end
end

# populate each of the maps (e.g. seed-to-soil)
0.upto(N-1) do |mx|
    mappings = $data[mx+1].split("\n").drop(1).map do |line|
        dst, src, len = line.scan(/\d+/).map(&:to_i)
        [Range.new(src, src+len-1), Range.new(dst, dst+len-1)]
    end
    maps[mx] = newMapFunc(mappings)
end


p1_locations = seeds.map do |val|
    0.upto(N-1) do |mx|
        val = maps[mx][val]
    end
    val
end
puts "p1: #{p1_locations.min}"

p2_locations = p2_seeds.map do |val|
    0.upto(N-1) do |mx|
        val = maps[mx][val]
    end
    val
end
puts "p2: #{p2_locations.min}"