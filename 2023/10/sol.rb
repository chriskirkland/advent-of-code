# https://adventofcode.com/2022/day/10
#$data = File.read("input.txt").split("\n")
#$data = File.read("sample.txt").split("\n")
$data = File.read("sample2.txt").split("\n")

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
        [nv, dir, [[start, dir]]]
    end

    until paths.empty?
        curr, dir, path = paths.shift
        cx, cy = curr
        next if cx < 0 || cx >= N || cy < 0  || cy >= M  # out of bounds
        next if $grid[cx][cy] == "."

        ndir = $TURN[dir][$grid[cx][cy]]
        next unless ndir # dead end
        nx, ny = vadd(curr, $MOVE[ndir])

        npath = path + [[[cx,cy], dir]] # extend path
        return npath if [nx, ny] == start # finished the loop

        paths.append [[nx, ny], ndir, npath]
    end
    raise "No pipe loop found"
end


COORDS = (0..N-1).to_a.product((0..M-1).to_a)
S = COORDS.find { |i, j| $grid[i][j] == "S"}

cycle = solve(S)
puts "p1: #{(cycle.size+1)/2}"

# replace S with necessary part base on start + end direction of loop
newS = case [cycle[0][1], cycle[-1][1]]
when [:DOWN, :LEFT], [:RIGHT, :UP]
  "F"
when [:DOWN, :RIGHT], [:LEFT, :UP]
  "7"
when [:UP, :LEFT], [:RIGHT, :DOWN]
  "L"
when [:UP, :RIGHT], [:LEFT, :DOWN]
  "J"
when [:LEFT, :RIGHT], [:RIGHT, :LEFT]
  "-"
when [:UP, :DOWN], [:DOWN, :UP]
  "|"
else
  raise "INVALID"
end
puts "cycle ends: #{[cycle[0], cycle[-1]]} => #{newS} @ #{S}"
$grid[S[0]][S[1]] = newS


### PART 2

$scaled = Array.new(2*N) { Array.new (2*M) { '.' } }
# copy in a 2X scaled up version fo the $grid
COORDS.each { |i,j| $scaled[2*i][2*j] = $grid[i][j] }

# fill in all connected segments of pipe as we scale up, path as well
path = cycle.map { |node| node[0] }.sort
spath = path.map { |i, j| [2*i,2*j] }

puts "cycle: #{cycle.sort}"
puts "path: #{path}"
COORDS.each do |i,j|
  puts "  ? (#{i},#{j})"
  if i < N - 1
    # look down the column
      if ["F", "7", "|"].include?($scaled[2*i][2*j]) && ["L", "J", "|"].include?($scaled[2*(i+1)][2*j])
        if path.include?([i,j]) && path.include?([i+1,j])
          puts "adding (#{2*i+1},#{2*j}) to path"
          spath.append([2*i+1,2*j])
        end
        $scaled[2*i+1][2*j] = "|"
      end
  end

  if j < M - 1
    # look across the row
    if ["F", "L", "-"].include?($scaled[2*i][2*j]) && ["7", "J", "-"].include?($scaled[2*i][2*(j+1)])
      if path.include?([i,j]) && path.include?([i,j+1])
        puts "adding (#{2*i},#{2*j+1}) to path"
        spath.append([2*i,2*j+1])
      end
      $scaled[2*i][2*j+1] = "-"
    end
  end
end
puts "path length #{path.size}"
puts "scaled path length #{spath.size}"
puts "spath: #{spath.sort}"

# fill in the path as well
#
puts ">>> SCALED UP"
$scaled.each do |line|
  puts line.join
end
puts


# all points not yet reached by flooding
$inside = (0..2*N-1).to_a.product((0..2*M-1).to_a).select { |i,j| !spath.include?([i,j]) }

def print_grid
    $scaled.each_with_index do |row, i|
        nrow = row.map.with_index do |c, j|
            if c == "."
              $inside.include?([i,j]) ? "I" : "O"
              #if i%2 == 1 || j%2 == 1
              #  " "
              #else
              #  $inside.include?([i,j]) ? "I" : "O"
              #end
            else
              c
            end
        end
        puts "#{nrow.to_a.join}"
    end
    puts
end

puts "----- BEFORE ----"
print_grid
puts

Q = [[0, 0]]
$inside.delete [0,0]

until Q.empty?
  pi, pj = Q.shift
  puts ">> visiting '#{$scaled[pi][pj]}' @ (#{pi},#{pj})"
  print_grid

  # enqueue all valid directions from pt
  [:UP, :DOWN, :LEFT, :RIGHT].each do |dir|
    ni, nj = vadd([pi, pj], $MOVE[dir])
    next unless $inside.include? [ni, nj]  # already visited or on the path

    puts " + '#{$scaled[ni][nj]}' @ (#{ni},#{nj})"
    $inside.delete [ni, nj] # point is reachable from outside
    Q.append [ni,nj]
  end
end

puts "----- AFTER ----"
print_grid
puts

normal_inside = $inside.select { |i,j| i%2 == 0 && j%2 == 0 }
puts  "p2: #{normal_inside.size}"
