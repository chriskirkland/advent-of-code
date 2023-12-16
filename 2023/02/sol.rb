# https://adventofcode.com/2022/day/2
$data = File.read("input.txt").split("\n")

def le(a, b)
    raise "mismatch" if a.length != b.length
    a.length.times do |i|
        return false if a[i] > b[i]
    end
    return true
end

colors = {
    "red" => 0,
    "green" => 1,
    "blue" => 2,
}

games = $data.map do |line|
     game_str, turns_str = line.split(":")
     gid = game_str.split(" ")[1].to_i
     reveals = turns_str.split(";").map do |turn|
        marbles = [0, 0, 0] # r,g,b
        turn.split(",").each do |part|
            num, c = part.split(" ")
            marbles[colors[c]] += num.to_i
        end
        marbles
     end
     [gid, reveals]
end

possible_gids = games.map do |gid, reveals|
    next unless reveals.all? { |r| le(r, [12, 13, 14]) }
    gid
end.compact
puts "p1: #{possible_gids.sum}"

powers = games.map do |gid, reveals|
    max = [0, 0, 0]
    (0..2).each do |ix|
        max[ix] = reveals.map { |r| r[ix] }.max
    end
    max.reduce(:*)
end
puts "p2: #{powers.sum}"