# https://adventofcode.com/2022/day/11
$data = File.read("input.txt").split("\n\n")

class Monkey
    attr_reader :items, :inspections
    def initialize(expr, quot, pass_to, fail_to)
        @items = []
        @inspections = 0
        @expr = expr
        @quot = quot
        @pass_to = pass_to
        @fail_to = fail_to
    end

    def operation(val, div: 3)
        puts "expression: #{@expr}"
        op1, operator, op2 = @expr.map { |op| 
            next val if op == "old"
            next op if "+*".include?(op)
            op.to_i
        }
        puts "executing: #{op1} #{operator} #{op2}"
        op1.send(operator.to_sym, op2) / 3
    end

    def test(val)
        val % @quot == 0 ? @pass_to : @fail_to
    end

    def inspect(val)
        @inspections += 1
        nval = operation(val)
        puts "new value: #{nval}"
        to = test(nval)
        [nval, to]
    end

    def self.build(config)
        lines = config.split("\n")
        expr = lines[2].split("=")[1].split
        puts "expression: #{expr}"
        quot = lines[3].split(" ")[-1].to_i
        puts "quot: #{quot}"
        true_to = lines[4].split(" ")[-1].to_i
        false_to = lines[5].split(" ")[-1].to_i
        puts "true_to: #{true_to}, false_to: #{false_to}"
        monkey = new(expr, quot, true_to, false_to)

        lines[1].split(":")[-1].split(",").map(&:to_i).each do |item|
            puts "adding item #{item}" 
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

puts "=== BUILDING MONKEYS ==="
monkeys = $data.map {|config| Monkey.build(config)}
print_state(monkeys)
puts
puts "=== RUNNING MONKEYS ==="

20.times do |round|
    monkeys.each_with_index do |monkey, ix|
        n = monkey.items.count
        n.times do
            item = monkey.items.shift
            puts "[Monkey #{ix}] inspecting item #{item}"

            nval, to = monkey.inspect(item)
            monkeys[to].items.push nval
            puts "[Monkey #{ix}] items after #{monkey.items.join(", ")}"
        end
        puts 
    end
    puts "After round #{round+1}, the monkeys are holding items with these worry levels:"
    print_state(monkeys)
end

puts monkeys.map(&:inspections).max(2).reduce(:*)