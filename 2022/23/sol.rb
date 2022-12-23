# https://adventofcode.com/2022/day/23
$data = File.read("input.txt").split("\n")
DEBUG = false

def debug(msg)
    puts msg if DEBUG
end

def vadd(v1, v2)
    [v1, v2].transpose.map(&:sum)
end

N, S, E, W = [-1, 0], [1, 0], [0, 1], [0, -1]
NW, NE, SW, SE = vadd(N,W), vadd(N,E), vadd(S,W), vadd(S,E)
DIR_TO_SYM = {N => :N, S => :S, E => :E, W => :W, NW => :NW, NE => :NE, SW => :SW, SE => :SE}
ALL_DIRS = [N, S, E, W, NW, NE, SW, SE]

require 'set'
$elves = Set.new

def borders
    minx, maxx = $elves.map(&:first).minmax
    miny, maxy = $elves.map(&:last).minmax
    [minx, miny, maxx, maxy]
end

def print_state
    minx, miny, maxx, maxy = borders
    # TODO remove this
    minx = [-2, minx].min
    maxx = [maxx, 9].max
    miny = [-3, miny].min
    maxy = [maxy, 10].max

    debug "num elves: #{$elves.size}"
    (minx..maxx).each do |x|
        debug (miny..maxy).map { |y|
            $elves.include?([x, y]) ? "#" : "."
        }.join
    end
end

$data.each_with_index do |line, x|
    line.chars.each_with_index do |ch, y|
        $elves.add [x, y] if ch == "#"
    end
end

debug "=== INITIAL STATE ==="
print_state

# [directions to check], {direction to move}
$check_move = [
    [[N, NE, NW], N],
    [[S, SE, SW], S],
    [[W, NW, SW], W],
    [[E, NE, SE], E]
]

1000000.times do |round|
    puts "=== ROUND #{round+1} ==="
    debug "priorities: #{$check_move.map { |_, dir| DIR_TO_SYM[dir] }.join ' > '}"
    # generate each elf's would-be position
    moves = Hash.new { |h, k| h[k] = [] }
    $elves.each do |elf|
        debug "trying to move elf #{elf}"
        unless ALL_DIRS.any? { |dir| $elves.include? vadd(elf, dir) }
            debug "  no elf neighbors. skipping."
            next
        end

        $check_move.each do |checks, move|
            debug "  checking #{checks}"
            npos = vadd(elf, move)
            conflicts = checks.select { |dir| $elves.include? vadd(elf, dir) }
            if conflicts.any?
                debug "  conflicts: #{conflicts.map { |dir| DIR_TO_SYM[dir] }.join ' '}"
                next
            end

            debug "  elf #{elf} would move #{DIR_TO_SYM[move]} to #{npos}"
            moves[npos] << elf
            break # go to the next elf
        end
    end

    # find the unique moves and apply them
    moves.select! { |_, elves| elves.size == 1 }
    unless moves.any?
        puts round+1
        break
    end

    moves.each do |npos, elves|
        debug "replacing #{elves.first} with #{npos}"
        $elves.delete elves.first
        $elves.add npos
    end
    print_state

    # rotate the moves
    $check_move.rotate!
end
#minx, miny, maxx, maxy = borders
#puts (minx..maxx).map { |x|
#    (miny..maxy).map { |y|
#        $elves.include?([x, y]) ? 0 : 1
#    }.sum
#}.sum