# https://adventofcode.com/2022/day/8
$data = File.read("input.txt").split("\n")
#$data = File.read("sample3.txt").split("\n")

ins = $data[0].chars.map { |c| c == "L" ? 0 : 1 }
G = $data[2..-1].map do |line|
    n, l, r = line.scan(/\w+/)
    [n, [l, r]]
end.to_h

### Part 1
#curr = 'AAA'
#steps = 0
#until curr == 'ZZZ'
#    curr =  G[curr][ins[steps % ins.length]]
#    steps += 1
#end
#puts "p1: #{steps}"

### part 2
$Q = G.keys.select { |k| k[2] == "A" }

# { [v, dir_offset] -> [steps first seen] }
visited = Hash.new
# cycles lengths for Z-nodes along each of the #Q paths
cycles = Array.new($Q.length) { {} }
allCycles = Array.new($Q.length) { false }

step = 0
allZ = false
until allZ || allCycles.all? do
    allZ = true
    #puts "step #{step}: #{$Q} (#{visited.length} visited, [#{cycles.map { |h| h.length }.join(",")}] cycles)"
    $Q = $Q.each_with_index do |v, pix| 
        dix = step % ins.length
        dir = ins[dix]

        # keep track of where we've visited in case we ever get a loop
        if visited[[v, dix]] && v[2] == "Z"
            # we've already seen this cycle, so we've recorded all cycles on this path.
            if !allCycles[pix] && cycles[pix][[v, dix]]
                allCycles[pix] = true
            end

            # we've hit a new cycle, record the length
            cycles[pix][[v, dix]] = step - visited[[v, dix]]
        else
            visited[[v, dix]] = step
        end

        # traverse to the next node
        nv = G[v][dir]
        allZ &= nv[2] == "Z"
        $Q[pix] = nv
    end.compact
    step += 1
end

if allZ
    # simple case: we found the all-Z condition without cycles
    puts "p2: #{}"
end

# complex case: we ran into cycles on each path, so gotta do some math to speed things
puts ">> found all cycles after #{step} steps"
cycles.each_with_index do |h, pix|
    h.each do |k, v|
        puts "[#{pix}] #{k} -> #{v}"
    end
end