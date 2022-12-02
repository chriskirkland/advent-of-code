packs = []
curr = 0
File.open('input.txt').each do |line|
    if line.strip == ""
        packs.push curr
        curr = 0
        next
    end

    curr += line.to_i
end
packs.sort!.reverse!

puts packs[0]
puts packs[0] + packs[1] + packs[2]
