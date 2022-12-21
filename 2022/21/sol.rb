# https://adventofcode.com/2022/day/21
$data = File.read("input.txt").split("\n")
DEBUG = true

def get_monkeys()
    $data.map { |line|
        parts = line.split(":")
        m = parts[0]
        expr = parts[1].strip.split(" ")
        if expr.length == 1
            [m, expr[0].to_i]
        else
            [m, expr]
        end
    }.to_h
end

def calc(monkeys, monkey)
    expr = monkeys[monkey]
    return expr if expr.is_a? Integer

    op = expr[1]
    v1, v2 = calc(monkeys, expr[0]), calc(monkeys, expr[2])
    v = v1.public_send(op, v2)
    puts "#{monkey} := #{v}" if DEBUG
    monkeys[monkey] = v
end

def p1
    monkeys = get_monkeys()
    #$data.each do |monkey, expr|
    #    puts "#{monkey} = #{expr}"
    #end
    
    calc(monkeys, "root")
end

def contains?(monkeys, monkey, target)
    return true if monkey == target

    expr = monkeys[monkey]
    return false if expr.is_a? Integer

    return true if expr.include? target
    return contains?(monkeys, expr[0], target) || contains?(monkeys, expr[2], target)
end

ME = "humn"
INVERSE = {"+" => "-", "-" => "+", "*" => "/", "/" => "*"}

def p2
    #  original input
    monkeys = get_monkeys

    # find the half of the tree which contains 'humn'
    l, _, r = monkeys["root"]
    solved, unsolved = l, r
    if contains?(monkeys, l, ME)
        unsolved, solved = l, r
    end
    puts "solved: #{solved}, unsolved: #{unsolved}" if DEBUG

    # calculate the value of the solved half
    val = calc(monkeys, solved)

    # work backwards toward human
    curr = unsolved
    while curr != ME
        l, op, r = monkeys[curr]
        puts "working back from #{curr} (val=#{val})" if DEBUG
        puts "  #{val} = #{l} #{op} #{r}" if DEBUG
        if contains?(monkeys, l, ME)
            puts "  #{l} contains #{ME}" if DEBUG
            v = calc(monkeys, r)
            puts "  #{r} = #{v}" if DEBUG
            puts "  doing #{val} #{INVERSE[op]} #{v}" if DEBUG
            val = val.public_send(INVERSE[op], v)
            curr = l
        else
            puts "  #{r} contains #{ME}" if DEBUG
            v = calc(monkeys, l)
            puts "  #{l} = #{v}" if DEBUG
            if ["+", "*"].include? op
                puts "  doing #{val} #{INVERSE[op]} #{v}" if DEBUG
                val = val.public_send(INVERSE[op], v)
            else
                puts "  doing #{v} #{op} #{val}" if DEBUG
                val = v.public_send(op, val)
            end
            curr = r
        end
        puts if DEBUG
    end
    val
end

puts "==== PART 1 ===="
puts p1
puts "==== PART 2 ===="
puts p2
