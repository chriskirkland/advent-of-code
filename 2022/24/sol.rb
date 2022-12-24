# https://adventofcode.com/2022/day/24
$data = File.read("input.txt").split("\n")
require 'rb_heap'
require 'set'

DEBUG = false
def debug(msg)
    puts msg if DEBUG
end

class Path
    attr_reader :path, :time
    def initialize(path, time: 0)
        @path = path
        @time = time
    end

    def end
        @path.last
    end

    def dist(target)
        cx, cy = self.end
        tx, ty = target
        (tx-cx).abs + (ty-cy).abs
    end

    def score(target)
        @time + self.dist(target)
    end

    def extend(step: nil)
        np = @path
        np += [step] if step
        Path.new(np, time: @time+1)
    end
end

ROWS, COLS = $data.size-2, $data[0].size-2
T = ROWS.lcm(COLS)

N, S, E, W = [-1, 0], [1, 0], [0, 1], [0, -1]
CHAR_TO_DIR = { "^" => N, "v" => S, ">" => E, "<" => W }

# calculates v1 + m*v2
def vadd(v1, v2)
    [v1, v2].transpose.map(&:sum)
end

def print_grid(grid)
    return unless DEBUG
    grid.each_with_index do |row, rx|
        puts row.map.with_index { |v, cx|
            if v.length > 0
                v.length == 1 ? v[0] : v.length
            else
                "."
            end
        }.join
    end
end

# T(ime) x ROWS x COLS 3D array. Since blizzards wrap, we know the grid repeats
# with a fixed period, 'T'.
debug "constructing blockage grid"
$grid = Array.new(T) { Array.new(ROWS+2) { Array.new(COLS+2) { [] }} }
$data.each_with_index do |line, r|
    line.chars.each_with_index do |ch, c|
        next if ch == "."  # open
        if ch == "#"  # wall
            T.times do |t|
                $grid[t][r][c] = ["#"]
            end
            next
        end

        #debug "(#{r},#{c},#{ch}) simulating blizzard"
        # generate the path of the blizzard
        if ["<", ">"].include? ch   # blizzard traverses a row
            positions = [r].product((1..COLS).to_a)  # all cells in that row, in order
            positions.rotate!(c-1)  # start at the given column
            positions.rotate!.reverse! if ch == "<" # reverse if blizzard is going left
        else  # blizzard traverses a column
            positions = ((1..ROWS).to_a).product([c])  # all celss in that column, in order
            positions.rotate!(r-1)  # start at the given row
            positions.rotate!.reverse! if ch == "^" # reverse if blizzard is going up
        end
        #debug "  path (#{T/positions.length} times): #{positions}"

        # map the path of the blizzard onto the 3D array
        npos = positions.length
        T.times do |t|
            #debug "  minute #{t+1}"
            pr, pc = positions[t % npos]
            $grid[t][pr][pc].push ch
        end
    end
end
debug "finished constructing grid"

debug "INITIAL STATE"
debug $data
puts

#$grid.each_with_index do |t, i|
#    puts "Minute #{i}"
#    print_grid t
#    puts
#end

er, ec = 0, $data.first.chars.find_index(".")
tr, tc = ROWS+1, $data.last.chars.find_index(".")
debug "expidition start at (#{er},#{ec}), end for (#{tr},#{tc})"

def find_shortest_path(start, target, start_time: 0)
    sr, sc = start
    tr, tc = target

    # Walk possible paths, priority queue by minimum possible distance to target
    visited = Set.new
    paths = Heap.new{ |a,b| a.score([tr, tc]) < b.score([tr, tc]) }
    paths << Path.new([[sr, sc]], time: start_time)
    while !paths.empty?
        #debug "num paths remaining: #{paths.size}"
        path = paths.pop
        if visited.include? [path.time, path.end]
            debug "skipping #{path.end} @ #{path.time} minutes"
            next
        end
        visited.add [path.time, path.end]

        er, ec = path.end
        gix = (path.time+1) % T
        debug "checking path from (#{er},#{ec}) @ #{path.time} minutes (#{paths.size} remaining)"
        debug "path length: #{path.time}"
        return path.time - start_time if er == tr && ec == tc # found it!

        [N, S, E, W].each do |dir| # try all of the legal moves
            nr, nc = vadd([er, ec], dir)
            next if nr < 0 || nr > ROWS+1 || nc < 0 || nc > COLS+1  # out of bounds
            paths << path.extend(step: [nr, nc]) unless $grid[gix][nr][nc].any?
        end
        paths << path.extend unless $grid[gix][er][ec].any?  # to stay put
    end
end

# part 1
j1 = find_shortest_path([er, ec], [tr, tc])
puts j1

# part 2
j2 = find_shortest_path([tr, tc], [er, ec], start_time: j1)
j3 = find_shortest_path([er, ec], [tr, tc], start_time: j1+j2)
puts j1 + j2 + j3