# https://adventofcode.com/2022/day/16
require 'set'
$data = File.read("sample.txt").split("\n")

$flow = {}
$adj = Hash.new { |h,k| h[k] = Set.new }
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
$edges = Hash.new { |h,k| h[k] = {} }
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
            next if p.include? nxt
            paths.push [p+[nxt], w+1] 
        end
    end
end

puts "reducing the edges to only valuable ones + the starting point"
$edges = $edges.select { |k,v| $valuable.include?(k) || k == START }
$edges = $edges.map { |k,v| 
    [k, v.select { |k2,v2| $valuable.include?(k2) }] 
}.to_h

def print_path(path)
    puts "Path: #{path.join(" -> ")}"
    tflow, rflow = 0, 0
    tstart = 1
    while path.any?
        v = path.shift
        if path.any?
            tend = tstart + $edges[v][path.first] + 1
        else 
            tend = 30
        end

        rflow += $flow[v]
        tflow += (tend-tstart) * rflow
        (tend-tstart).times do |t|
            puts "#{rflow}"
        end
        #puts "== Minute #{tstart} to #{tend-1}"
        #puts "Valve #{v}"
        #puts "New flow rate is #{rflow}"
        #puts "Total flow is #{tflow} at minute #{tend-1}"
        tstart = tend
    end
    puts #{rflow}
end

puts "calculating max flow path"
# (path, timeleft, flow value of path so far)
paths = [[[START], 30, 0]]
maxp = []
p1 = 0
while paths.any?
    path, tleft, flow = paths.shift
    if flow > p1
        p1 = flow
        maxp = path
    end

    left_to_try = $valuable-path
    left_to_try.each do |v|
        ntleft = tleft - $edges[path.last][v] - 1
        next if ntleft <= 0
        nflow = flow + ntleft * $flow[v]
        paths.push [path+[v], ntleft, nflow]
    end
end
puts p1