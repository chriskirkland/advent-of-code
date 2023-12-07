# https://adventofcode.com/2022/day/19
$data = File.read("sample.txt").split("\n").map { |line| 
    # 0: blueprint
    # 1: ore bot cost in ore
    # 2: clay bot cost in ore
    # 3: obisidian bot cost in ore
    # 4: obisidian bot cost in clay
    # 5: geode bot cost in ore
    # 6: geode bot cost in obsidian
    line.scan(/\d+/).map(&:to_i)
}

DEBUG = true
def debug(msg = "")
    puts msg if DEBUG
end

ROBOT_PRIORITY = [:geode, :obsidian, :clay, :ore]
ROBOT_INDEX = ROBOT_PRIORITY.map.with_index { |r, i| [r, i] }.to_h

def vadd(v1, v2, c: 1)
    raise "not the same size" unless v1.size == v2.size
    v1.zip(v2).map { |a, b| a + c * b }
end

def vgt(v1, v2)
    raise "not the same size (#{v1.size}, #{v2.size})" unless v1.size == v2.size
    v1.zip(v2).all? { |a, b| a >= b }
end

class Blueprint
    attr_accessor :resources, :robots, :building, :to_build
    def initialize(costs, resources: [0,0,0,0], robots: [0,0,0,1], building: [0,0,0,0], to_build: [0,0,0,0])
        # geodes > obsidian > clay > ore for all vars
        @costs = costs
        @resources = resources
        @robots = robots
        @building = building
        @to_build = to_build
    end

    def buy!(robot)
        debug "  buying one #{robot}"
        rix = ROBOT_INDEX[robot]
        @to_build[rix] += 1 
        @resources = vadd(@resources, @costs[rix], c: -1)
    end

    def can_buy?(robot)
        rix = ROBOT_INDEX[robot]
        vgt(@resources, @costs[rix])
    end

    def produce
        # collect ores
        @resources = vadd(@resources, @robots)

        # finish building in progress robots and reset robots to build
        @robots = vadd(@robots, @building)
        @building = @to_build
        @to_build = [0, 0, 0, 0]
    end

    def geodes
        @resources[0]
    end

    def print_state(force: false)
        puts "resources: " + @resources.zip(ROBOT_PRIORITY).map { |r, n| "#{r} #{n}(s)" }.join(", ") if DEBUG || force
        puts "robots: " + @robots.zip(ROBOT_PRIORITY).map { |r, n| "#{r} #{n}(s)" }.join(", ") if DEBUG || force
        puts "building: " + @building.zip(ROBOT_PRIORITY).map { |r, n| "#{r} #{n}(s)" }.join(", ") if DEBUG || force
    end

    def clone
        Blueprint.new(@costs, resources: @resources.dup, robots: @robots.dup, building: @building.dup)
    end
end

MINS = 27

#$maxg = Hash.new
#def max_geodes_for_blueprint(bp, mins)
#    debug "#maxg = #{$maxg.size}"
#    return bp.geodes if mins <= 0
#    debug "[#{MINS-mins}m] finding max for #{bp.robots} w/ #{bp.resources}"
#
#    $maxg[[vadd(bp.robots, bp.resources), mins]] ||= begin
#        options = []
#        ROBOT_PRIORITY.each do |robot|
#            next unless bp.can_buy?(robot)
#            # buy one of that robot and DON'T advance time. assume we've already produced for this minute.
#            opt = bp.clone
#            opt.buy! robot 
#            options << [opt, mins]
#        end
#
#        # produce ore, then robots
#        bp.produce
#        options << [bp.clone, mins-1] # don't by anything, advance time
#
#        options.map { |opt, m| max_geodes_for_blueprint(opt, m) }.max
#    end
#end

total = 0
$data.take(1).each do |c|
    debug "BLUEPRINT #{c[0]}"
    bp = Blueprint.new([
      [0, c[6], c[5], 0],  # cost for a geode bot in (geode, obsidian, clay, ore)
      [0, 0, c[4], c[3]],  # cost for an obsidian bot
      [0, 0, 0, c[2]],     # cost for a clay bot
      [0, 0, 0, c[1]]      # cost for an ore bot
    ])

    #geodes = max_geodes_for_blueprint(bp, MINS)
    #puts "blueprint #{c[0]} yields #{geodes}"
    #total += (c[0] + 1) * geodes

    MINS.times do |m|
        debug "== MINUTE #{m} =="
        bp.print_state

        # produce resources, then robots
        bp.produce

        # buy robots based on priority
        ROBOT_PRIORITY.each do |robot|
            bp.buy! robot while bp.can_buy?(robot)
        end
    end
    total += c[0] * bp.geodes
end
puts total
