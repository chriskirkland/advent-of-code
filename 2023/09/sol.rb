# https://adventofcode.com/2022/day/9
$data = File.read("input.txt").split("\n")

# build the sequence diagrams
S = $data.map do |line|
    seqs = []
    seq = line.scan(/[-\d]+/).map(&:to_i) 
    seqs << seq
    while seq.any? { |v| v != 0 } 
        seq = (1..seq.size-1).map do |i|
            seq[i]-seq[i-1]
        end.to_a
        seqs << seq
    end 
    seqs
end


ends = S.map do |seqs|
    seqs.map { |s| s.last }.sum
end
puts "p1: #{ends.sum}"

begs = S.map do |seqs|
    # add the placeholders
    seqs.append Array.new(seqs.last.length-1, 0)
    seqs.each { |s| s.unshift(0)}

    # calculate the new first value
    (seqs.length-2).downto(0) do |sx|
        seqs[sx][0] = seqs[sx][1] - seqs[sx+1][0]
    end
    seqs[0][0]
end
puts "p2: #{begs.sum}"