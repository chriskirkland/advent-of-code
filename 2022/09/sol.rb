# https://adventofcode.com/2022/day/9
$data = File.read("input.txt").split("\n").map{|x| x.split(" ")}.map{|x| [x[0].to_sym, x[1].to_i]}

require "set"

class Point
    attr_accessor :x, :y
    def initialize(x, y)
        @x, @y = x, y
    end

    def dist(a)
        [(a.x-self.x).abs, (a.y-self.y).abs].max
    end

    def add(a)
        self.x += a.x
        self.y += a.y
    end

    # move one unit in the direction of point a
    def step(a)
        self.x += (a.x-self.x)/(a.x-self.x).abs if a.x != self.x
        self.y += (a.y-self.y)/(a.y-self.y).abs if a.y != self.y
    end

    # needed to use Set
    def eql?(a)
        self.x == a.x && self.y == a.y
    end

    def hash
        [self.x, self.y].hash
    end
end

DELTA = {
    "R": Point.new(0, 1),
    "L": Point.new(0, -1),
    "D": Point.new(1, 0),
    "U": Point.new(-1, 0),
}

def solve(n)
    knots = Array.new(n) { Point.new(0, 0)}
    visited = Set.new [Point.new(0, 0)]

    $data.each do |dir, steps|
        h = knots[0]
        steps.times do
            h.add DELTA[dir]
            1.upto(n-1) do |i|
                pt, t = knots[i-1], knots[i]
                t.step pt if t.dist(pt) > 1
                visited.add t if i == n-1
            end
        end
    end
    visited.length
end

puts solve(2)
puts solve(10)