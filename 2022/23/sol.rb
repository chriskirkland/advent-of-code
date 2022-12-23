# https://adventofcode.com/2022/day/23
$data = File.read("input.txt").split("\n")

def vadd(v1, v2)
    [v1, v2].transpose.map(&:sum)
end

N, S, E, W = [-1, 0], [1, 0], [0, 1], [0, -1]
NW, NE, SW, SE = vadd(N,W), vadd(N,E), vadd(S,W), vadd(S,E)
ALL_DIRS = [N, S, E, W, NW, NE, SW, SE]
DIR_TO_SYM = {N => :N, S => :S, E => :E, W => :W, NW => :NW, NE => :NE, SW => :SW, SE => :SE}

require 'set'
$elves = Set.new

def borders
    minx, maxx = $elves.map(&:first).minmax
    miny, maxy = $elves.map(&:last).minmax
    [minx, miny, maxx, maxy]
end

$data.each_with_index do |line, x|
    line.chars.each_with_index do |ch, y|
        $elves.add [x, y] if ch == "#"
    end
end

# [[directions to check], {direction to move}]
$check_move = [
    [[N, NE, NW], N],
    [[S, SE, SW], S],
    [[W, NW, SW], W],
    [[E, NE, SE], E]
]

1000.times do |round|
    # generate each elf's would-be position
    moves = Hash.new { |h, k| h[k] = [] }
    conflicts = Hash.new { |h, e| h[e] = ALL_DIRS.select { |dir| $elves.include? vadd(e, dir) } }
    $elves.each do |elf|
        next unless conflicts[elf].any? # no neighbors, skip

        $check_move.each do |checks, move|
            npos = vadd(elf, move)
            dir_conflicts = conflicts[elf] & checks
            next if dir_conflicts.any? # try next direction

            moves[npos] << elf
            break # go to the next elf
        end
    end

    # find the unique moves and apply them
    moves.select! { |_, elves| elves.size == 1 }
    unless moves.any?
        # part 2
        puts round+1
        break
    end
    moves.each do |npos, elves|
        $elves.delete elves.first
        $elves.add npos
    end

    # rotate the moves
    $check_move.rotate!


    if round+1 == 10
        # part 1
        minx, miny, maxx, maxy = borders
        puts (minx..maxx).map { |x|
            (miny..maxy).map { |y|
                $elves.include?([x, y]) ? 0 : 1
            }.sum
        }.sum
    end
end