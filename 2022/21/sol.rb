# https://adventofcode.com/2022/day/21
$data = File.read("input.txt").split("\n").map { |line|
    parts = line.split(":")
    m = parts[0]
    expr = parts[1].strip.split(" ")
    if expr.length == 1
        [m, expr[0].to_i]
    else
        [m, expr]
    end
}.to_h

$data.each do |monkey, expr|
    puts "#{monkey} = #{expr}"
end

def calc(monkey)
    mv = $data[monkey]
    return mv if mv.is_a? Integer

    puts "calculating #{monkey} = #{mv}"
    op = mv[1]
    v1, v2 = calc(mv[0]), calc(mv[2])
    v = v1.public_send(op, v2)
    puts "overwriting #{monkey} with #{v}"
    $data[monkey] = v
end

puts calc("root")
