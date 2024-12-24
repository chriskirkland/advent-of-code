# https://adventofcode.com/2024/day/4
$data = File.read("input.txt").split("\n")

S = $data.map do |line|
    line.split('')
end
N, M = S.size, S[0].size

# sr - starting row index
# sc - starting col index
# deltas - offsets to check (e.g. DIRECTIONS members)
# expected - the expected values to match (as a char array)
def match?(sr, sc, deltas, expected)
    deltas.each.with_index do |(dr, dc), i|
        return false if sr+dr < 0 || sr+dr >= N
        return false if sc+dc < 0 || sc+dc >= M
        return false if S[sr+dr][sc+dc] != expected[i]
    end
    true
end

def matches(expected, directions)
    count = 0
    S.each.with_index do |row, r|
        row.each.with_index do |char, c|
            directions.each do |name, deltas|
                count += 1 if match?(r, c, deltas, expected)
            end
        end
    end
    count
end

P1_TARGETS = ['XMAS', 'SAMX']
P1_DIRECTIONS = {
    'RIGHT' => [[0, 0], [0, 1], [0, 2], [0, 3]],
    'DOWN' => [[0, 0], [1, 0], [2, 0], [3, 0]],
    'RIGHT_DOWN' => [[0, 0], [1, 1], [2, 2], [3, 3]],
    'LEFT_DOWN' => [[0, 0], [1, -1], [2, -2], [3, -3]],
}


p1 = P1_TARGETS.map {|target| matches(target.split(''), P1_DIRECTIONS)}.sum
puts "#{p1}"

P2_TARGETS = ['ASMSM', 'ASMMS', 'AMSSM', 'AMSMS']
P2_DIRECTIONS = {
    "X" => [[0, 0], [-1, -1], [1, 1], [-1, 1], [1, -1]],
}

p2 = P2_TARGETS.map {|target| matches(target.split(''), P2_DIRECTIONS)}.sum
puts p2