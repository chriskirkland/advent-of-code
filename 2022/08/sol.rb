# https://adventofcode.com/2022/day/8
$data = File.read("input.txt").split("\n")

def print_grid(grid)
   grid.each do |row|
     puts row.join("")
   end
   puts
end

N, M = $data.length, $data[0].length
$grid = $data.map{_1.chars.map(&:to_i)}

#####################################################################################
############################# PART 1 ################################################
#####################################################################################
### height necessary for point to be visible from a direction
vhf = Array.new(4) {
    Array.new(N) {
        Array.new(M, 0)
    }
}
UP, LEFT, DOWN, RIGHT = 0, 1, 2, 3
dirs = ["UP", "LEFT", "DOWN", "RIGHT"]

# scan top + bottom
M.times do |j|
    # move inwards from top and bottom
    (1..N-1).each do |i|
        # i steps down, looking up
        vhf[UP][i][j] = [$grid[i-1][j], vhf[UP][i-1][j]].max
        # i steps up, looking down
        vhf[DOWN][N-i-1][j] = [$grid[N-i][j], vhf[DOWN][N-i][j]].max
    end
end

# scan left + right
N.times do |i|
    # move inwards from left and right
    (1..M-1).each do |j|
        # j steps right, looking left
        vhf[LEFT][i][j] = [$grid[i][j-1], vhf[LEFT][i][j-1]].max
        # j steps left, looking right
        vhf[RIGHT][i][M-j-1] = [$grid[i][M-j], vhf[RIGHT][i][M-j]].max
    end
end

visible = 2 * (N+M-2) # borders are visible
(1..(N-2)).each do |i|
    (1..(M-2)).each do |j|
        [UP, LEFT, DOWN, RIGHT].each do |dir|
            if $grid[i][j] > vhf[dir][i][j]
                visible += 1
                break
            end
        end
    end
end
puts "Part 1: #{visible}"

#####################################################################################
############################# PART 2 ################################################
#####################################################################################
def find_dist(dir, i, j)
    case dir
    when UP
        (i-1).downto(0).each do |k|
            return i-k if $grid[k][j] >= $grid[i][j]
        end
        return i
    when LEFT
        (j-1).downto(0).each do |k|
            return j-k if $grid[i][k] >= $grid[i][j]
        end
        return j
    when DOWN
        (i+1...N-1).each do |k|
            return k-i if $grid[k][j] >= $grid[i][j]
        end
        return N-1-i
    when RIGHT
        (j+1...M-1).each do |k|
            return k-j if $grid[i][k] >= $grid[i][j]
        end
        return M-1-j
    end
end

# I hate everything... just brute force it
max = 0
(1..(N-2)).each do |i|
    (1..(M-2)).each do |j|
        score = 1
        dirs.each_with_index do |dir, d|
            score *= find_dist(d, i, j)
        end
        if score > max
            max = score 
        end
    end
end
puts "Part 2: #{max}"