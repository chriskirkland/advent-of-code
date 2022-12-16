# https://adventofcode.com/2022/day/16
require 'set'
$data = File.read("input.txt").split("\n")

$flow = {}
$adj = Hash.new { |h,k| h[k] = Set.new }
$edges = Hash.new { |h,k| h[k] = {} }
START = "AA"

# mark the initial edges
$data.each do |line|
    valves = line.scan(/[A-Z]{2}/).flatten
    from = valves.shift
    $flow[from] = line.scan(/\d+/).flatten[0].to_i
    $adj[from].add from
    valves.each do |to|
        $adj[from].add to
        $adj[to].add from
    end
end
$valuable = $flow.keys.select { |k| $flow[k] > 0 }

# DFS from each node to find min distance between each pair of nodes
$adj.keys.each do |start|
    $edges[start][start] = 0
    paths = $adj[start].map { |v| [[start, v], 1] unless v == start }.compact
    while paths.any?
        p, w = paths.shift
        v = p.last
        unless $edges[start][v] # already visited
            $edges[start][v] = w
            $edges[v][start] = w
        end

        $adj[v].each do |nxt| 
            paths.push [p+[nxt], w+1] unless p.include? nxt
        end
    end
end

# compact edges to only include valuable nodes (mostly for debugging)
$edges = $edges.select { |k,v| $valuable.include?(k) || k == START }
$edges = $edges.map { |k,v| 
    [k, v.select { |k2,v2| $valuable.include?(k2) }] 
}.to_h

def solve(interesting, time: 30)
    # (path, timeleft, flow value of path so far)
    paths = [[[START], time, 0]]
    p1 = 0
    while paths.any?
        path, tleft, flow = paths.shift
        p1 = [flow, p1].max

        (interesting-path).each do |v|
            ntleft = tleft - $edges[path.last][v] - 1
            next if ntleft <= 0
            nflow = flow + ntleft * $flow[v]
            paths.push [path+[v], ntleft, nflow]
        end
    end
    p1
end

# part 1
puts solve($valuable)

# part 2
max = 0
1.upto($valuable.length/2) do |n|
    $valuable.combination(n).each do |mine|
        v = solve(mine, time: 26) + solve($valuable-mine, time: 26)
        max = v if v > max
    end
end
puts max