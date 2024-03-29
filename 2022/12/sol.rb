# https://adventofcode.com/2022/day/12
$input = File.read("input.txt").split("\n").map(&:chars)
heights = ('a'..'z').zip(26.downto(1)).to_h.merge({'S' => 26, 'E' => 1})
$grid = $input.map{ |row| row.map{ heights[_1]}}

N = $input.count
M = $input[0].count

def find_all(*chs)
    $input.each_with_index.map { |row, i|
        row.each_with_index.map { |col, j|
            [i, j] if chs.include? $input[i][j]
        }
    }.flatten(1).compact
end

def solve(*goals)
    dist = Array.new(N) { Array.new(M, N*M) }

    sx, sy = find_all('E').first
    dist[sx][sy] = 0
    queue = [[sx, sy]]
    while queue.count > 0
        x, y = queue.shift

        [[x-1, y], [x+1, y], [x, y-1], [x, y+1]].each do |nx, ny|
            next unless nx >= 0 && nx <= N-1 && ny >= 0 && ny <= M-1 # boundary checks
            next unless $grid[nx][ny] <= $grid[x][y] + 1 # can only climb 1 unit
            next unless dist[x][y]+1 < dist[nx][ny] # proposed path is shorter than previous paths

            dist[nx][ny] = dist[x][y]+1 
            queue.push [nx, ny]
        end
    end

    find_all(*goals).map { |gx, gy| dist[gx][gy] }.min
end

puts solve('S')
puts solve('S', 'a')
