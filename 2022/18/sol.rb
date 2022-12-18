# https://adventofcode.com/2022/day/18
DEBUG = false
$data = File.read("input.txt").split("\n").map{|x| x.scan(/-?\d+/).map(&:to_i)}

def print_state(components)
    puts if DEBUG
    puts "=============================" if DEBUG
    components.each_with_index do |(pts, sa),ix|
        puts "component #{ix+1} with SA #{sa}" if DEBUG
        pts.each do |pt|
            puts "  #{pt}" if DEBUG
        end
    end
    puts "=============================" if DEBUG
end

def build_components(data)
    components = []
    data.each do |x,y,z|
        print_state components

        puts "adding point [#{x},#{y},#{z}]" if DEBUG
        # find the components with points adjacent to this one
        cadj = Array.new(components.size, 0)
        adjp = [[x-1,y,z],[x+1,y,z],[x,y-1,z],[x,y+1,z],[x,y,z-1],[x,y,z+1]]
        components.each_with_index do |(comp, sa), ix|
            adjp.each do |a|
                next unless comp.include? a
                cadj[ix] += 1
            end
        end

        # no adjacent components
        if cadj.count(0) == cadj.size
            puts "creating new component" if DEBUG
            components.push [[[x,y,z]], 6]
            next
        end

        # join all adjacement components
        cixs = cadj.each_index.select{ |i| cadj[i] > 0 }.reverse
        puts "components to join: #{cixs}" if DEBUG
        to_join = cixs.map{ |ix| components.delete_at(ix) }
        newc = to_join.map{ |pts, sa| pts }.flatten(1) + [[x,y,z]]
        newsa = to_join.map{ |pts, sa| sa }.sum + 6 - 2 * cadj.sum
        components.push [newc, newsa]
    end
    print_state components
    components

end

droplets = build_components($data)
p1 = droplets.map{ |(pts, sa)| sa }.sum
puts p1

# experimentally saw that input points are <= 20 in each dimension
puts "PART 2" if DEBUG
MAX = $data.map{ |pt| pt.max }.max
puts "MAX = #{MAX}"
all_points = (0..MAX).map { |x|
    (0..MAX).map { |y|
        (0..MAX).map { |z|
            [x,y,z]
        }
    }
}.flatten(2)
empty_space = all_points - $data
anti_droplets = build_components(empty_space)

# find the bounded components
print_state anti_droplets
p2 = 0
anti_droplets.each do |(pts, sa)|
    bounded = true
    pts.each do |pt|
        if pt.any? { |x| x == 0 || x == MAX }
            bounded = false
            break
        end
    end
    p2 += sa if bounded
end
puts p1-p2