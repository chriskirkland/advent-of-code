# https://adventofcode.com/2022/day/12
$heights = ('a'..'z').zip(1..26).to_h.merge({'S' => 1, 'E' => 26})

$input = File.read("input.txt").split("\n").map(&:chars)

def find_all(ch)
    results = []
    $input.each_with_index do |row, i|
        row.each_with_index do |col, j|
            if $input[i][j] == ch
                results.push [i, j]
            end
        end
    end
    results
end

def solve
    grid = $input.map{ |row| row.map{ $heights[_1]}}

    n = $input.count
    m = $input[0].count
    dist = Array.new(n) { Array.new(m, n*m) }

    #grid.each do |row|
    #    puts "#{row}"
    #end

    # TODO: turn this into a heap?
    sx, sy = find_all('S').first
    dist[sx][sy] = 0
    queue = [[sx, sy]]
    while queue.count > 0
        x, y = queue.shift
        #puts "([#{x},#{y}]=#{grid[x][y]}) searching..."

        is_candidate = ->(nx, ny) {
            #puts "([#{x},#{y}]=#{grid[x][y]},d#{dist[x][y]}) checking ([#{nx},#{ny}]=#{grid[nx][ny]}),d#{dist[nx][ny]}"
            grid[nx][ny] <= grid[x][y] + 1 && dist[x][y]+1 < dist[nx][ny]
        }
        visit = ->(nx, ny) {
            #puts "([#{x},#{y}]=#{grid[x][y]},d#{dist[x][y]}) enqueueing [#{nx},#{ny}]"
            dist[nx][ny] = dist[x][y]+1 
            queue.push [nx, ny]
        }

        visit.call(x-1, y) if x > 0 && is_candidate.call(x-1, y)
        visit.call(x+1, y) if x < n-1 && is_candidate.call(x+1, y)
        visit.call(x, y-1) if y > 0 && is_candidate.call(x, y-1)
        visit.call(x, y+1) if y < m-1 && is_candidate.call(x, y+1)
    end
    ex, ey = find_all('E').first
    dist[ex][ey]
end

puts solve()