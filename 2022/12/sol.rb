# https://adventofcode.com/2022/day/12
$heights = ('a'..'z').zip(26.downto(1)).to_h.merge({'S' => 26, 'E' => 1})

$input = File.read("input.txt").split("\n").map(&:chars)

def find_all(*chs)
    $input.each_with_index.map { |row, i|
        row.each_with_index.map { |col, j|
            [i, j] if chs.include? $input[i][j]
        }
    }.flatten(1).compact
end

def solve(*goals)
    grid = $input.map{ |row| row.map{ $heights[_1]}}

    n = $input.count
    m = $input[0].count
    dist = Array.new(n) { Array.new(m, n*m) }

    sx, sy = find_all('E').first
    dist[sx][sy] = 0
    queue = [[sx, sy]]
    while queue.count > 0
        x, y = queue.shift

        is_candidate = ->(nx, ny) {
            grid[nx][ny] <= grid[x][y] + 1 && dist[x][y]+1 < dist[nx][ny]
        }
        visit = ->(nx, ny) {
            dist[nx][ny] = dist[x][y]+1 
            queue.push [nx, ny]
        }

        visit.call(x-1, y) if x > 0 && is_candidate.call(x-1, y)
        visit.call(x+1, y) if x < n-1 && is_candidate.call(x+1, y)
        visit.call(x, y-1) if y > 0 && is_candidate.call(x, y-1)
        visit.call(x, y+1) if y < m-1 && is_candidate.call(x, y+1)
    end

    find_all(*goals).map{ |x, y| dist[x][y] }.min
end

puts solve('S')
puts solve('S', 'a')