# https://adventofcode.com/2022/day/9
$data = File.read("input.txt").split("\n").map{|x| x.split(" ")}.map{|x| [x[0].to_sym, x[1].to_i]}
DEBUG = false

require "set"

DELTA = {
    "R": [0, 1],
    "L": [0, -1],
    "D": [1, 0],
    "U": [-1, 0],
}

def solve(n)
    puts "=== START ===" if DEBUG
    knots = Array.new(n) { Array.new(2) { 0 } }

    visited = Set.new
    visited.add [0, 0]

    $data.each do |dir, steps|
        puts "moving #{dir} #{steps} steps" if DEBUG
        h = knots[0]
        steps.times do |s|
            # move the head one step
            h[0] += DELTA[dir][0]
            h[1] += DELTA[dir][1]
            puts "[s#{s}] head: #{h}" if DEBUG

            # move each tail one step (if needed)
            1.upto(n-1) do |i|
                pt, t = knots[i-1], knots[i]
                puts "[s#{s},t#{i}] curr: #{t}" if DEBUG
                puts "[s#{s},t#{i}] prev: #{pt}" if DEBUG
                if (pt[0]-t[0]).abs > 1 || (pt[1]-t[1]).abs > 1
                    # move 1 unit in each direction the head is away from the tail
                    t[1] += (pt[1]-t[1])/(pt[1]-t[1]).abs if pt[1] != t[1]
                    t[0] += (pt[0]-t[0])/(pt[0]-t[0]).abs if pt[0] != t[0]
                    puts "[s#{s},t#{i}] final: #{t}" if DEBUG
                    if i == n-1
                        puts "[s#{s},t#{i}] adding #{t}" if DEBUG
                        visited.add t.dup 
                    end
                end
            end
        end
        puts if DEBUG
    end
    visited.length
end

puts solve(2)
puts solve(10)