# https://adventofcode.com/2022/day/22
$vmap, $path = File.read("input.txt").split("\n\n")
$vmap = $vmap.split("\n")
DEBUG = false

INF = 1 << 30
CHAR_TO_INT = {" " => 0, "." => 1, "#" => INF}
INT_TO_CHAR = CHAR_TO_INT.invert
RIGHT, DOWN, LEFT, UP = (0..3).to_a
DIR_TO_CHAR = [">", "v", "<", "^"]
OPPOSITE_DIR = [LEFT, UP, RIGHT, DOWN]
DIR_TO_DELTA = [[0,1], [1,0], [0,-1], [-1,0]]

HEIGHT = $vmap.length
WIDTH = $vmap.map { _1.length }.max

# make the map 2 cells wider and taller to avoid checking boundary conditions
$map = Array.new(HEIGHT+2) { Array.new(WIDTH+2) { 0 } }
def print_map(path: {})
    $map.each_with_index do |row, r|
        puts row.each_with_index.map { |ch, c|
            dir = path[[r,c]]
            dir ? DIR_TO_CHAR[dir] : INT_TO_CHAR[ch] 
        }.join if DEBUG
    end
end

$vmap.each_with_index do |line, row|
    line.chars.each_with_index do |ch, col|
        $map[row+1][col+1] = CHAR_TO_INT[ch]
    end
end
print_map
puts if DEBUG

def vadd(v1, v2)
    [v1, v2].transpose.map(&:sum)
end

path_steps = $path.scan(/\d+/).map(&:to_i)
path_turns = $path.scan(/[LR]/)

# starting position
pr, pc = 1, $map[1].find_index(1)
direction = RIGHT
path = {}

path_steps.each_with_index do |steps, ix|
    puts "instruction '#{steps}#{path_turns[ix]}'" if DEBUG
    puts "position (#{pr}, #{pc}) heading #{DIR_TO_CHAR[direction]} (#{HEIGHT} x #{WIDTH})" if DEBUG

    path[[pr,pc]] = direction
    # do the steps (if possible)
    steps.times do |s|
        nr, nc = vadd([pr, pc], DIR_TO_DELTA[direction])
        puts "  doing step #{s} to (#{nr},#{nc})" if DEBUG

        case $map[nr][nc]
        when 1  # can take a step
            pr, pc = nr, nc
        when INF  # hit a wall
            break
        when 0  # need to wrap around
            nr, nc = pr, pc
            backwards = OPPOSITE_DIR[direction]
            while true
                # check the boundaries
                #break if direction == LEFT && nc == WIDTH-1
                #break if direction == RIGHT && nc == 0
                #break if direction == UP && nr == HEIGHT-1
                #break if direction == DOWN && nr == 0

                tr, tc = vadd([nr,nc], DIR_TO_DELTA[backwards])
                break if $map[tr][tc] == 0
                nr, nc = tr, tc
            end
            next if $map[nr][nc] == INF # wall at the other end
            pr, pc = nr, nc
        end

        path[[pr, pc]] = direction
    end

    # turn to face the new direction
    if ix < path_turns.length
        direction += (path_turns[ix] == "L" ? -1 : 1)
        direction %= 4
        puts "new direction: #{DIR_TO_CHAR[direction]}" if DEBUG
    end

    #print_map(path: path)
    puts if DEBUG
end

puts "final position: #{pr}, #{pc} heading #{DIR_TO_CHAR[direction]}"
puts 1000 * pr + 4 * pc + direction