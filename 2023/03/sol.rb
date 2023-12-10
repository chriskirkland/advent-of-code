# https://adventofcode.com/2022/day/3
$data = File.read("input.txt").split("\n")

non_symbols = (0..9).map(&:to_s) + ["."]

$N, $M = $data.size, $data[0].size
$symG = Array.new($N) { Array.new($M) {false} }
$gearG = Array.new($N) { Array.new($M) {false} }

$data.each_with_index do |line, row|
    line.strip.split('').each_with_index do |ch, col|
        unless non_symbols.include?(ch)
            $symG[row][col] = true
        end
        $gearG[row][col] = true if ch == "*"

    end
end

# adjacent coordinates in the provided grid
def adj(adjM, row, cols)
    ncols = [cols[0]-1] + cols + [cols[-1]+1]
    to_check = []
    to_check += ncols.map { |col| [row-1, col]}  # row above
    to_check +=  ncols.map { |col| [row+1, col]}  # row below
    to_check << [row, cols[0]-1]  # left
    to_check << [row, cols[-1]+1]  # right

    to_check.select do |r, c|
        next false if r < 0 || r >= $N || c < 0 || c >= $M
        adjM[r][c]
    end
end

parts = []
gears = {}
gears.default = []

$data.each_with_index do |line, row|
    line.scan(/\d+/) do |num|
        sx, ex = $~.offset(0) # beg and (exclusive) end of match
        if adj($symG, row, (sx..ex-1).to_a).any?
            parts << num.to_i
        end

        adj($gearG, row, (sx..ex-1).to_a).each do |gc|
            gears[gc] += [num.to_i]
        end
    end
end

puts "p1: #{parts.sum}"

gear_rations = gears.select { |_, v| v.size == 2 }.values.map do |vs|
    vs.reduce(:*)
end
puts "p2: #{gear_rations.sum}"