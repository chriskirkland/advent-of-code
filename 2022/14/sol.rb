# https://adventofcode.com/2022/day/14
$data = File.read("input.txt").split("\n").map { |wall|
    wall.split(" -> ").map { |pt| pt.split(",").map(&:to_i) }
}

require 'set'
$slice = Hash.new { |h,k| h[k] = "#" }

# find bounds: xmin, xmax, ymin, ymax
def bounds()
    coords = $slice.keys.to_set
    [
        coords.map { |pt| pt[0] }.min,
        coords.map { |pt| pt[0] }.max,
        coords.map { |pt| pt[1] }.min,
        coords.map { |pt| pt[1] }.max,
    ]
end

def print_grid
    # grid is transposed for printing
    xmin, xmax, ymin, ymax = bounds()
    0.upto(ymax) do |y|
        s = ""
        xmin.upto(xmax) do |x|
            s += $slice.include?([x,y]) ? $slice[[x,y]] : "."
        end
        puts s
    end
end

def range(a,b)
    a < b ? (a..b) : a.downto(b)
end

# add the rock structures
$data.each do |wall|
    prev = wall.shift
    while wall.any?
        pt = wall.shift

        if prev[0] == pt[0] # vertical
            range(prev[1], pt[1]).each do |y|
                $slice[[prev[0], y]] = "#"
            end
        else # horizontal
            range(prev[0], pt[0]).each do |x|
                $slice[[x, prev[1]]] = "#"
            end
        end
        prev = pt
    end
end

def solve(with_floor: false)
    xmin, xmax, _, ymax = bounds()
    if with_floor
        (xmin-ymax-2).upto(xmax+ymax+2) do |x|
            $slice[[x, ymax+2]] = "#"
        end
        ymax += 2
    end

    units = 0
    while true
        nx, ny = 500, 0
        return units if $slice.include? [nx, ny]

        settled = false
        while !settled
            return units if ny > ymax

            if !$slice.include? [nx, ny+1] # can flow down
                ny += 1
                next
            elsif !$slice.include? [nx-1, ny+1] # can flow down left
                nx, ny = nx-1, ny+1
                next
            elsif !$slice.include? [nx+1, ny+1] # can flow down right
                nx, ny = nx+1, ny+1
                next
            else # sand is trapped
                settled = true
                $slice[[nx, ny]] = "o"
            end

            units += 1
        end
    end
end

p1 = solve()
puts p1
puts p1 + solve(with_floor: true) # sand is preserved from p1