# https://adventofcode.com/2022/day/18
$data = File.read("input.txt").split("\n").map{|x| x.split(",").map(&:to_i)}

def build_connected_components(data)
    components = []
    data.each do |x,y,z|
        # find the components with points adjacent to this one
        cadj = Array.new(components.size, 0)
        adjp = [[x-1,y,z],[x+1,y,z],[x,y-1,z],[x,y+1,z],[x,y,z-1],[x,y,z+1]]
        components.each_with_index do |(comp, sa), ix|
            adjp.each do |a|
                cadj[ix] += 1 if comp.include? a
            end
        end

        # no adjacent components
        if cadj.count(0) == cadj.size
            components.push [[[x,y,z]], 6]
            next
        end

        # join all adjacement components
        cixs = cadj.each_index.select{ |i| cadj[i] > 0 }.reverse
        to_join = cixs.map{ |ix| components.delete_at(ix) }
        newc = to_join.map{ |pts, sa| pts }.flatten(1) + [[x,y,z]]
        newsa = to_join.map{ |pts, sa| sa }.sum + 6 - 2 * cadj.sum
        components.push [newc, newsa]
    end

    components
end

# PART 1
droplets = build_connected_components($data)
p1 = droplets.map{ |(pts, sa)| sa }.sum
puts p1

# PART 2
# find all points in the complement to the droplets
MAX = $data.map{ |pt| pt.max }.max
all_points = (0..MAX).map { |x| (0..MAX).map { |y| (0..MAX).map { |z| [x,y,z] } } }.flatten(2)
empty_space = all_points - $data
anti_droplets = build_connected_components(empty_space)

# find the bounded components of the empty space and calculate their surface area
p2 = 0
anti_droplets.each do |(pts, sa)|
    bounded = true
    pts.each do |pt|
        next unless pt.any? { |x| x == 0 || x == MAX }
        bounded = false
        break
    end
    p2 += sa if bounded
end
puts p1-p2