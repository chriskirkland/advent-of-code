def clone_array(arr)
    Marshal.load(Marshal.dump(arr))
end

sns = File.read("input.txt")
stack_sn, move_sn = sns.split("\n\n")
stack_lines = stack_sn.split("\n").reverse
N = stack_lines.shift.split(" ").map(&:to_i).max

stacks = Array.new(N) {[]}
while stack_lines.length > 0 
    line = stack_lines.shift
    N.times do |ix|
        crate = line[4*ix+1]
        if crate != " "
            stacks[ix].push crate
        end
    end
end

moves = move_sn.split("\n")
instr = moves.map { |move|
    ws = move.split(" ")
    [ws[1], ws[3], ws[5]].map(&:to_i)
}

p1_stacks = clone_array(stacks)
instr.each do |amt,from,to|
    amt.times do
        moving = p1_stacks[from-1].pop
        p1_stacks[to-1].push moving
    end
end
p1 = p1_stacks.map{|s| s.pop}.join("")
puts "Part 1: #{p1}"

instr.each do |amt,from,to|
    moving = stacks[from-1].pop(amt)
    stacks[to-1] += moving
end
p2 = stacks.map{|s| s.pop}.join("")
puts "Part 2: #{p2}"