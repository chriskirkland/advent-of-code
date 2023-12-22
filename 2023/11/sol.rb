# https://adventofcode.com/2022/day/11
$data = File.read("input.txt").split("\n")
N, M = $data.size, $data[0].size

galaxies = $data.each_with_index.map do |row, i|
    matches = row.chars.each_index.select { |j| row[j] == "#" }
    next nil if matches.empty?
    matches.map { |j| [i, j] }
end.compact.flatten(1)

def expand(coords, factor = 2)
    ng = coords.dup

    # find the empty rows and columns
    empty_rows = (0..N-1).select do |i|
        ng.select { |x, _| x == i }.empty?
    end
    empty_cols = (0..M-1).select do |j|
        ng.select { |_, y| y == j }.empty?
    end

    # grow empty rows by factor
    empty_rows.reverse.each do |i|
        ng.map! { |x, y| x < i ? [x, y] : [x+(factor-1), y] }
    end
    empty_cols.reverse.each do |j|
        ng.map! { |x, y| y < j ? [x, y] : [x, y+(factor-1)] }
    end

    ng
end

def dist(x, y)
    (x[0]-y[0]).abs + (x[1]-y[1]).abs
end

def solve(coords, factor = 2)
    newc = expand(coords, factor)

    total = 0
    numc = newc.size
    (0..numc-1).each do |i|
        (i+1..numc-1).each do |j|
            dij = dist(newc[i], newc[j])
            total += dij
        end
    end

    total
end


puts "p1: #{solve(galaxies)}"
puts "p2: #{solve(galaxies, 1_000_000)}"