# Let 
#   OC = opponent's choice (0 = Rock/1 = Paper/2 = Scissors)
#   MC = my's choice
#   R  = result (0 = loss/1 = draw/2 = win)
# Then
#   R  = (MC - OC + 1) mod 3
# And
#   MC = (OC + R - 1) mod 3

def score_p1(game)
    oc, mc = game[0], game[1]
    r = (mc - oc + 1) % 3
    return 3 * r + mc + 1
end

def score_p2(game)
    oc, r = game[0], game[1]
    mc = (oc + r + 2) % 3  # 2 = -1 mod 3
    return 3 * r + mc + 1
end

input = File.read("input.txt")
data = input.split("\n").map {|a|
    trim = a.chars()
    [trim[0].ord - 'A'.ord, trim[2].ord - 'X'.ord]
}

p1 = data.map { |game| score_p1(game) }.sum
puts "Part 1: #{p1}"

p2 = data.map { |game| score_p2(game) }.sum
puts "Part 2: #{p2}"
