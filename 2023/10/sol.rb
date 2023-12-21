# https://adventofcode.com/2022/day/10
#$data = File.read("input.txt").split("\n")
$data = File.read("sample.txt").split("\n")

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

# construct a grid with an extra barrier of '.'s
$grid = $data.map { |line| ("."+line+".").chars }
$grid.prepend Array.new($grid.first.size, '.')
$grid.append  Array.new($grid.first.size, '.')
N, M  = $grid.size, $grid[0].size
puts "#### GRID"
$grid.each do |line|
  puts "#{line.join}"
end
puts

def vadd(a, b)
    [a[0] + b[0], a[1] + b[1]]
end

def solve(start)
    visited = {}
    visited.default = false
    # [position, from_direction, path]
    paths = $MOVE.map do |dir, move|
        nv = vadd(start, move)
        [nv, dir, [start, nv]]
    end

    until paths.empty?
        curr, dir, path = paths.shift
        cx, cy = curr
        next if cx < 0 || cx >= N || cy < 0  || cy >= M  # out of bounds
        next if $grid[cx][cy] == "."

        ndir = $TURN[dir][$grid[cx][cy]]
        next unless ndir # dead end
        nx, ny = vadd(curr, $MOVE[ndir])

        return path if [nx, ny] == start # finished the loop

        paths.append [[nx, ny], ndir, path + [[nx, ny]]] # extend path
    end
    raise "No pipe loop found"
end


COORDS = (0..N-1).to_a.product((0..M-1).to_a)
S = COORDS.find { |i, j| $grid[i][j] == "S"}

cycle = solve(S)
puts "p1: #{(cycle.size+1)/2}"

def dist_to_edge(i, j)
  [i, N-1-i, j, M-1-j].min
end


# rings of given distance from the edge (min distance among both coordinates is EXACTLY $dist)
def ring(dist, &block)
    raise "no block" unless block_given?

    COORDS.each do |i, j|
        next unless dist_to_edge(i, j) == dist
        yield [i, j]
    end
end

# pipe piece orthogonal to the direction of travel (i.e. stops a path to outside)
ORTHO = {
    RIGHT: "|",
    LEFT: "|",
    UP: "-",
    DOWN: "-",
}

# '.' points outside the loop
$outside = {}
ring(0) do |i, j|
    # draw an extra outside boundary
    $outside[[i,j]] = true
end
puts "outside: #{$outside}"

def print_outside
    $grid.each_with_index do |row, i|
        nrow = row.map.with_index do |c, j|
            if c == "."
                $outside[[i,j]] ? "O" : "I"
            else
              c
            end
        end
        puts "#{nrow.to_a.join}"
    end
    puts
end


# traverse rings from outside to inside, repeating until nothing changes
pass = 1
begin
  puts "****** PASS # #{pass} ******"
  changed = false
  min_outside = COORDS.map {|i, j| dist_to_edge(i, j) if $outside[[i,j]]}.compact.min

  (min_outside..[N,M].min/2).each do |off|
      puts
      puts "#### RING #{off}"
      print_outside

      ring(off) do |i, j|
          next if $outside[[i,j]] # no need to check neighbors
          puts "[r#{off}] '#{$grid[i][j]}' @ (#{i},#{j})"

          neigbors_outside = $MOVE.map do |dir, move|
              ni, nj = vadd([i, j], move)
              # neighbor is outside and doesn't block the path outside in the given direction
              outside = $outside[[ni,nj]] && $grid[ni][nj] != ORTHO[dir]
              puts "  neighbor '#{$grid[ni][nj]} @ (#{ni},#{nj}) outside? #{outside}"
              outside
          end
          if neigbors_outside.any?
            $outside[[i,j]] = true
            changed = true
          end
      end
  end
  pass += 1

end until !changed

puts
puts "#### FINAL"
print_outside
