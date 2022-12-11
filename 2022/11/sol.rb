# https://adventofcode.com/2022/day/11
$data = File.read("input.txt").split("\n\n")

class Monkey
    attr_reader :items, :inspections, :quot
    def initialize(expr, quot, pass_to, fail_to)
        @items = []
        @inspections = 0
        @expr = expr
        @quot = quot
        @pass_to = pass_to
        @fail_to = fail_to
    end

    def operation(val, mod: nil)
        op1, operator, op2 = @expr.map { |op| 
            next val if op == "old"
            next op if "+*".include?(op)
            op.to_i
        }
        tval = op1.send(operator.to_sym, op2)
        return tval % mod if mod
        tval / 3
    end

    def test(val)
        val % @quot == 0 ? @pass_to : @fail_to
    end

    def inspect(val, mod: nil)
        @inspections += 1
        nval = operation(val, mod: mod)
        to = test(nval)
        [nval, to]
    end

    def self.build(config)
        lines = config.split("\n")
        expr = lines[2].split("=")[1].split
        quot = lines[3].split(" ")[-1].to_i
        true_to = lines[4].split(" ")[-1].to_i
        false_to = lines[5].split(" ")[-1].to_i
        monkey = new(expr, quot, true_to, false_to)

        lines[1].split(":")[-1].split(",").map(&:to_i).each do |item|
            monkey.items.push item
        end
        monkey
    end
end

def print_state(monkeys)
    monkeys.each_with_index do |m,i|
        puts "Monkey #{i}: #{m.items.join(", ")} (#{m.inspections})"
    end
end

def solve(monkeys, rounds, cap: nil)
    rounds.times do |round|
        monkeys.each_with_index do |monkey, ix|
            n = monkey.items.count
            n.times do
                item = monkey.items.shift
                nval, to = monkey.inspect(item, mod: cap)
                monkeys[to].items.push nval
            end
        end
    end
    monkeys.map(&:inspections).max(2).reduce(:*)
end

# part 1
monkeys = $data.map {|config| Monkey.build(config)}
puts solve(monkeys, 20)

# part 2
monkeys = $data.map {|config| Monkey.build(config)}
lcm = monkeys.map(&:quot).reduce(1, :lcm)
puts solve(monkeys, 10000, cap: lcm)