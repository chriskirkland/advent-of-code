# https://adventofcode.com/2022/day/10
$data = File.read("input.txt").split("\n")
#$data = File.read("sample.txt").split("\n")

$MOVE = {
    DOWN: [1, 0],
    RIGHT: [0, 1],
    UP: [-1, 0],
    LEFT:  [0, -1],
}

# direction to turn based on direction we're heading and next segment
$TURN = {
    # moving down
    DOWN: {
        "L" => :RIGHT,
        "|" => :DOWN,
        "J" => :LEFT,
    },
    # moving right
    RIGHT: {
        "-" => :RIGHT,
        "J" => :UP,
        "7" => :DOWN,
    },
    # moving up
    UP: {
        "|" => :UP,
        "7" => :LEFT,
        "F" => :RIGHT,
    },
    # moving left
    LEFT: {
        "-" => :LEFT,
        "L" => :UP,
        "F" => :DOWN,
    }
}

$grid = $data.map { |line| line.chars }
N, M  = $grid.size, $grid[0].size

def vadd(a, b)
    [a[0] + b[0], a[1] + b[1]]
end

def solve(start)
    visited = {}
    visited.default = false
    # [position, from_direction, path_length]
    paths = $MOVE.map { |dir, move| [vadd(start, move), dir, 1] }
    #puts "starting paths: #{paths}"

    until paths.empty?
        #puts
        #puts "NUM PATHS: #{paths.size}"
        curr, dir, dist = paths.shift
        cx, cy = curr
        #puts ">> visiting '#{$grid[cx][cy]}' @ #{curr} traveling #{dir} (#{dist})"
        next if cx < 0 || cx >= N || cy < 0  || cy >= M  # out of bounds
        next if $grid[cx][cy] == "."

        ndir = $TURN[dir][$grid[cx][cy]]
        next unless ndir # dead end
        #puts "going #{ndir}"
        nx, ny = vadd(curr, $MOVE[ndir])

        return dist + 1 if [nx, ny] == start # finished the loop

        #puts "moving #{ndir} to #{[nx, ny]} (#{dist + 1}))"
        paths.append [[nx, ny], ndir, dist + 1] # extend path
    end
    raise "No pipe loop found"
end


S = (0...N-1).to_a.product((0..M-1).to_a).find { |i, j| $grid[i][j] == "S"}
#puts "S @ #{S}"

cycle_length = solve(S)
puts "p1: #{cycle_length/2}"
